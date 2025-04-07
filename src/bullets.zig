const std: type = @import("std");
const rl: type = @import("raylib");

const Animator: type = @import("animator.zig");
const Consts: type = @import("consts.zig");

pub const BulletType: type = enum {
    bullet,
    rocket,
    pulse,
    zap,
};

var bullets: std.ArrayList(Bullet) = undefined;
var bulletTextures: [4]rl.Texture2D = .{ undefined, undefined, undefined, undefined };

pub const bulletConfigs: [4]Animator.AnimationConfig = .{
    .{
        .color = rl.Color.white,
        .frames = 4,
        .duration = 0.05,
        .size = Consts.BULLET_SIZE,
    },
    .{
        .color = rl.Color.white,
        .frames = 3,
        .duration = 0.05,
        .size = Consts.BULLET_SIZE,
    },
    .{
        .color = rl.Color.white,
        .frames = 10,
        .duration = 0.05,
        .size = Consts.BULLET_SIZE,
    },
    .{
        .color = rl.Color.white,
        .frames = 8,
        .duration = 0.05,
        .size = Consts.BULLET_SIZE,
    },
};

const Bullet: type = struct {
    position: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    velocity: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    bulletType: BulletType = .bullet,
    angle: f32 = 90.0,
    color: rl.Color = rl.Color.white,
    friendly: bool = false,
    destroyed: bool = false,
    animationData: Animator.AnimationData = .{},

    pub fn init(x: f32, y: f32, vx: f32, vy: f32, bulletType: BulletType, angle: f32, color: rl.Color, friendly: bool) Bullet {
        var bullet: Bullet = .{
            .position = rl.Vector2.init(x, y),
            .velocity = rl.Vector2.init(vx, vy),
            .bulletType = bulletType,
            .angle = angle,
            .color = color,
            .friendly = friendly,
            .destroyed = false,
        };

        Animator.init(
            Bullet,
            &bullet,
            bulletTextures[@intFromEnum(bulletType)],
            bulletConfigs[@intFromEnum(bulletType)],
        );

        Animator.start(Bullet, &bullet);

        return bullet;
    }

    pub fn update(self: *Bullet, deltaTime: f32) void {
        self.position.x += self.velocity.x * deltaTime;
        self.position.y += self.velocity.y * deltaTime;

        if (self.position.x < 0 or self.position.x >= 1.0 or self.position.y < 0 or self.position.y >= 1.0) {
            self.destroyed = true;
        }

        if (self.animationData.running) {
            Animator.update(Bullet, self, deltaTime);
        }
    }

    pub fn draw(self: *Bullet) void {
        Animator.draw(Bullet, self, self.position.x, self.position.y, self.angle + 90.0);
    }
};

pub fn init(allocator: std.mem.Allocator) anyerror!void {
    bullets = std.ArrayList(Bullet).init(allocator);

    const buffer: []u8 = try allocator.alloc(u8, 100);
    defer allocator.free(buffer);

    for (0..bulletTextures.len) |i| {
        const fileName: [*:0]const u8 = try std.fmt.bufPrintZ(buffer, "resources/bullets/bullet{d}.png", .{i});

        bulletTextures[i] = try rl.loadTexture(fileName);
    }
}

pub fn deinit() void {
    bullets.deinit();

    for (0..bulletTextures.len) |i| {
        rl.unloadTexture(bulletTextures[i]);
    }
}

pub fn add(x: f32, y: f32, vx: f32, vy: f32, bulletType: BulletType, angle: f32, color: rl.Color, friendly: bool) anyerror!void {
    const angleRad: f32 = std.math.degreesToRadians(angle);

    try bullets.append(Bullet.init(
        x,
        y,
        @cos(angleRad) * vx,
        @sin(angleRad) * vy,
        bulletType,
        angle,
        color,
        friendly,
    ));
}

pub fn update(deltaTime: f32) void {
    var i: usize = 0;

    while (i < bullets.items.len) {
        var bullet: *Bullet = &bullets.items[i];

        bullet.update(deltaTime);

        if (bullet.destroyed) {
            _ = bullets.orderedRemove(i);

            continue;
        }

        i += 1;
    }
}

pub fn draw() void {
    for (bullets.items) |*bullet| {
        bullet.draw();
    }
}
