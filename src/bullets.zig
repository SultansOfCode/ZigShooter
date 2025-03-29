const std: type = @import("std");
const rl: type = @import("raylib");

const Consts: type = @import("consts.zig");

pub const BulletType: type = enum {
    bullet,
    rocket,
    pulse,
    zap,
};

const BulletConfig: type = struct {
    frames: usize = 1,
    animationVelocity: f32 = 0.05,
};

const Bullet: type = struct {
    position: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    velocity: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    bulletType: BulletType = .bullet,
    angle: f32 = 90.0,
    color: rl.Color = rl.Color.white,
    friendly: bool = false,
    destroyed: bool = false,
    animationFrame: usize = 0,
    animationTimer: f32 = 0,

    pub fn init(x: f32, y: f32, vx: f32, vy: f32, bulletType: BulletType, angle: f32, color: rl.Color, friendly: bool) Bullet {
        return Bullet{
            .position = rl.Vector2.init(x, y),
            .velocity = rl.Vector2.init(vx, vy),
            .bulletType = bulletType,
            .angle = angle,
            .color = color,
            .friendly = friendly,
            .destroyed = false,
            .animationTimer = bulletConfigs[@intFromEnum(bulletType)].animationVelocity,
        };
    }

    pub fn update(self: *Bullet, deltaTime: f32) void {
        self.position.x += self.velocity.x * deltaTime;
        self.position.y += self.velocity.y * deltaTime;

        if (self.position.x < 0 or self.position.x >= 1.0 or self.position.y < 0 or self.position.y >= 1.0) {
            self.destroyed = true;
        }

        self.animationTimer -= deltaTime;

        if (self.animationTimer <= 0.0) {
            const bulletConfig: BulletConfig = bulletConfigs[@intFromEnum(self.bulletType)];

            self.animationTimer += bulletConfig.animationVelocity;

            self.animationFrame += 1;

            if (self.animationFrame >= bulletConfig.frames) {
                self.animationFrame = 0;
            }
        }
    }

    pub fn draw(self: Bullet) void {
        const sourceRect: rl.Rectangle = .{
            .x = @as(f32, @floatFromInt(self.animationFrame)) * Consts.BULLET_SIZE,
            .y = 0.0,
            .width = Consts.BULLET_SIZE,
            .height = Consts.BULLET_SIZE,
        };

        rl.gl.rlPushMatrix();
        rl.gl.rlTranslatef(
            self.position.x * @as(f32, @floatFromInt(rl.getScreenWidth())),
            self.position.y * @as(f32, @floatFromInt(rl.getScreenHeight())),
            0.0,
        );
        rl.gl.rlRotatef(self.angle + 90.0, 0.0, 0.0, 1.0);
        rl.drawTextureRec(
            bulletTextures[@intFromEnum(self.bulletType)],
            sourceRect,
            rl.Vector2.init(
                -Consts.BULLET_SIZE_HALF,
                -Consts.BULLET_SIZE_HALF,
            ),
            self.color,
        );
        rl.gl.rlPopMatrix();
    }
};

const bulletConfigs: [4]BulletConfig = .{
    BulletConfig{
        .frames = 4,
        .animationVelocity = 0.05,
    },
    BulletConfig{
        .frames = 3,
        .animationVelocity = 0.05,
    },
    BulletConfig{
        .frames = 10,
        .animationVelocity = 0.05,
    },
    BulletConfig{
        .frames = 8,
        .animationVelocity = 0.05,
    },
};

var bullets: std.ArrayList(Bullet) = undefined;
var bulletTextures: [4]rl.Texture2D = undefined;

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

    try bullets.append(Bullet.init(x, y, @cos(angleRad) * vx, @sin(angleRad) * vy, bulletType, angle, color, friendly));
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
    for (bullets.items) |bullet| {
        bullet.draw();
    }
}
