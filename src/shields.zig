const std: type = @import("std");
const rl: type = @import("raylib");

const Animator: type = @import("animator.zig");
const Consts: type = @import("consts.zig");

pub const ShieldType: type = enum {
    front,
    front_and_side,
    round,
    invincibility,
};

var shield: Shield = .{};
var shieldTextures: [4]rl.Texture2D = .{undefined} ** 4;

pub const shieldConfigs: [4]Animator.AnimationConfig = .{
    .{
        .color = rl.Color.white,
        .frames = 10,
        .duration = 0.05,
        .size = Consts.SHIELD_SIZE,
    },
    .{
        .color = rl.Color.white,
        .frames = 6,
        .duration = 0.05,
        .size = Consts.SHIELD_SIZE,
    },
    .{
        .color = rl.Color.white,
        .frames = 12,
        .duration = 0.05,
        .size = Consts.SHIELD_SIZE,
    },
    .{
        .color = rl.Color.white,
        .frames = 10,
        .duration = 0.05,
        .size = Consts.SHIELD_SIZE,
    },
};

const Shield: type = struct {
    shieldType: ShieldType = .front,
    animationData: Animator.AnimationData = .{},

    pub fn update(self: *Shield, deltaTime: f32) void {
        Animator.update(Shield, self, deltaTime);
    }

    pub fn draw(self: *Shield, x: f32, y: f32) void {
        Animator.draw(Shield, self, x, y, 0.0);
    }
};

pub fn init(allocator: std.mem.Allocator) anyerror!void {
    const buffer: []u8 = try allocator.alloc(u8, 100);
    defer allocator.free(buffer);

    for (0..shieldTextures.len) |i| {
        const fileName: [*:0]const u8 = try std.fmt.bufPrintZ(buffer, "resources/shields/shield{d}.png", .{i});

        shieldTextures[i] = try rl.loadTexture(fileName);
    }
}

pub fn deinit() void {
    for (0..shieldTextures.len) |i| {
        rl.unloadTexture(shieldTextures[i]);
    }
}

pub fn setShield(shieldType: ShieldType) void {
    shield.shieldType = shieldType;

    Animator.init(
        Shield,
        &shield,
        shieldTextures[@intFromEnum(shieldType)],
        shieldConfigs[@intFromEnum(shieldType)],
    );

    Animator.start(Shield, &shield);
}

pub fn getShield() ShieldType {
    return shield.shieldType;
}

pub fn update(deltaTime: f32) void {
    shield.update(deltaTime);
}

pub fn draw(x: f32, y: f32) void {
    shield.draw(x, y);
}
