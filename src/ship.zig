const std: type = @import("std");
const rl: type = @import("raylib");

const Bullets: type = @import("bullets.zig");
const Consts: type = @import("consts.zig");
const Shields: type = @import("shields.zig");
const Weapons: type = @import("weapons.zig");

const ShipControl: type = enum {
    keyboard,
    mouse,
};

const ShipDamage: type = enum {
    none,
    low,
    middle,
    high,
};

pub const Ship: type = struct {
    position: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    velocity: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    control: ShipControl = .mouse,
    damage: ShipDamage = .none,
    shootCooldown: f32 = 0.0,
    shieldCooldown: f32 = 0.0,
    weapon: Weapons.WeaponType = .bullet_single_front,

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

        if (self.shieldCooldown > 0.0) {
            Shields.update(deltaTime);
        }
    }

    fn draw(self: *Ship) void {
        const x: i32 = @as(i32, @intFromFloat((self.position.x * @as(f32, @floatFromInt(rl.getScreenWidth()))) - Consts.SHIP_SIZE_HALF));
        const y: i32 = @as(i32, @intFromFloat((self.position.y * @as(f32, @floatFromInt(rl.getScreenHeight()))) - Consts.SHIP_SIZE_HALF));

        rl.drawTexture(shipDamagedTextures[@intFromEnum(self.damage)], x, y, rl.Color.white);

        if (self.shieldCooldown > 0.0) {
            Shields.draw(self.position.x, self.position.y);
        }
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
        ship.velocity.x -= Consts.SHIP_VELOCITY_X;
    }

    if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)) {
        ship.velocity.x += Consts.SHIP_VELOCITY_X;
    }

    if (rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up)) {
        ship.velocity.y -= Consts.SHIP_VELOCITY_Y;
    }

    if (rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.down)) {
        ship.velocity.y += Consts.SHIP_VELOCITY_Y;
    }

    if (ship.velocity.x != 0.0 and ship.velocity.y != 0.0) {
        ship.velocity.x /= std.math.sqrt2;
        ship.velocity.y /= std.math.sqrt2;
    }

    if (ship.shootCooldown > 0.0) {
        ship.shootCooldown -= deltaTime;
    } else if ((ship.control == .keyboard and rl.isKeyDown(rl.KeyboardKey.space)) or (ship.control == .mouse and rl.isMouseButtonDown(rl.MouseButton.left))) {
        ship.shootCooldown += Consts.SHIP_SHOOT_COOLDOWN;

        try Weapons.shoot(ship);
    }

    if (ship.shieldCooldown > 0.0) {
        ship.shieldCooldown -= deltaTime;
    }

    if (rl.isMouseButtonPressed(rl.MouseButton.right)) {
        var shield: u8 = @intFromEnum(Shields.getShield());

        shield += 1;

        if (shield >= Shields.shieldConfigs.len) {
            shield = 0;
        }

        Shields.setShield(@enumFromInt(shield));

        ship.shieldCooldown = 10.0;
    }
}

pub fn update(deltaTime: f32) void {
    ship.update(deltaTime);
}

pub fn draw() void {
    ship.draw();
}
