const std: type = @import("std");
const rl: type = @import("raylib");
const Consts: type = @import("consts.zig");
const Bullets: type = @import("bullets.zig");
const Stars: type = @import("stars.zig");

const ShipDamage: type = enum {
    none,
    low,
    middle,
    high,
};

const Ship: type = struct {
    position: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    velocity: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    damage: ShipDamage = .none,
    shootCooldown: f32 = 0.0,
    bullet: Bullets.BulletType = .bullet,

    fn update(self: *Ship, deltaTime: f32) void {
        self.position.x = std.math.clamp(
            self.position.x + self.velocity.x * deltaTime,
            Consts.SHIP_SIZE_HALF / @as(f32, @floatFromInt(rl.getScreenWidth())),
            1.0 - Consts.SHIP_SIZE_HALF / @as(f32, @floatFromInt(rl.getScreenWidth())),
        );

        self.position.y = std.math.clamp(
            self.position.y + self.velocity.y * deltaTime,
            Consts.SHIP_SIZE_HALF / @as(f32, @floatFromInt(rl.getScreenHeight())),
            1.0 - Consts.SHIP_SIZE_HALF / @as(f32, @floatFromInt(rl.getScreenHeight())),
        );

        ship.velocity.x = 0.0;
        ship.velocity.y = 0.0;
    }

    fn draw(self: *Ship) void {
        const x: i32 = @as(i32, @intFromFloat((self.position.x * @as(f32, @floatFromInt(rl.getScreenWidth()))) - Consts.SHIP_SIZE_HALF));
        const y: i32 = @as(i32, @intFromFloat((self.position.y * @as(f32, @floatFromInt(rl.getScreenHeight()))) - Consts.SHIP_SIZE_HALF));

        rl.drawTexture(shipDamagedTextures[@intFromEnum(self.damage)], x, y, rl.Color.white);
    }
};

var ship: Ship = Ship{};
var shipDamagedTextures: [4]rl.Texture2D = undefined;

pub fn init(allocator: std.mem.Allocator) anyerror!void {
    ship.position.x = 0.5;
    ship.position.y = 0.95;

    const buffer: []u8 = try allocator.alloc(u8, 100);
    defer allocator.free(buffer);

    for (0..shipDamagedTextures.len) |i| {
        const fileName: [*:0]const u8 = try std.fmt.bufPrintZ(buffer, "resources/ship/ship{d}.png", .{i});

        shipDamagedTextures[i] = try rl.loadTexture(fileName);
    }
}

pub fn deinit() void {
    for (0..shipDamagedTextures.len) |i| {
        rl.unloadTexture(shipDamagedTextures[i]);
    }
}

pub fn processInputs(deltaTime: f32) anyerror!void {
    if (rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left)) {
        ship.velocity.x = -Consts.SHIP_VELOCITY_X;
    }

    if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)) {
        ship.velocity.x = Consts.SHIP_VELOCITY_X;
    }

    if (rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up)) {
        ship.velocity.y = -Consts.SHIP_VELOCITY_Y;
    }

    if (rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.down)) {
        ship.velocity.y = Consts.SHIP_VELOCITY_Y;
    }

    if (ship.velocity.x != 0.0 and ship.velocity.y != 0.0) {
        ship.velocity.x /= std.math.sqrt2;
        ship.velocity.y /= std.math.sqrt2;
    }

    if (ship.shootCooldown > 0.0) {
        ship.shootCooldown -= deltaTime;
    } else if (rl.isMouseButtonDown(rl.MouseButton.left)) {
        ship.shootCooldown += Consts.SHIP_SHOOT_COOLDOWN;

        try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, ship.bullet, 255.0, rl.Color.yellow, true);
        try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, ship.bullet, 270.0, rl.Color.yellow, true);
        try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, ship.bullet, 285.0, rl.Color.yellow, true);
    }

    if (rl.isMouseButtonPressed(rl.MouseButton.right)) {
        var bullet: u8 = @intFromEnum(ship.bullet);

        bullet += 1;

        if (bullet == 4) {
            bullet = 0;
        }

        ship.bullet = @enumFromInt(bullet);
    }
}

pub fn update(deltaTime: f32) void {
    ship.update(deltaTime);
}

pub fn draw() void {
    ship.draw();
}
