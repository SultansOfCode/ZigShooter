const rl: type = @import("raylib");

const Bullets: type = @import("bullets.zig");
const Consts: type = @import("consts.zig");
const Ship: type = @import("ship.zig");

pub const WeaponType: type = enum {
    bullet_single_front,
    rocket_single_front,
    pulse_single_front,
    zap_single_front,
    bullet_triple_front,
    rocket_triple_front,
    pulse_triple_front,
    zap_triple_front,
    bullet_quintuple_front,
    rocket_quintuple_front,
    pulse_quintuple_front,
    zap_quintuple_front,
    bullet_triple_burst,
    rocket_triple_burst,
    pulse_triple_burst,
    zap_triple_burst,
    bullet_quintuple_burst,
    rocket_quintuple_burst,
    pulse_quintuple_burst,
    zap_quintuple_burst,
};

pub const ShootType: type = enum {
    front,
    burst,
};

pub const WeaponConfig: type = struct {
    bulletType: Bullets.BulletType,
    bulletCount: usize,
    shootType: ShootType,
};

pub const weaponConfigs: [20]WeaponConfig = .{
    .{
        .bulletType = .bullet,
        .bulletCount = 1,
        .shootType = .front,
    },
    .{
        .bulletType = .rocket,
        .bulletCount = 1,
        .shootType = .front,
    },
    .{
        .bulletType = .pulse,
        .bulletCount = 1,
        .shootType = .front,
    },
    .{
        .bulletType = .zap,
        .bulletCount = 1,
        .shootType = .front,
    },
    .{
        .bulletType = .bullet,
        .bulletCount = 3,
        .shootType = .front,
    },
    .{
        .bulletType = .rocket,
        .bulletCount = 3,
        .shootType = .front,
    },
    .{
        .bulletType = .pulse,
        .bulletCount = 3,
        .shootType = .front,
    },
    .{
        .bulletType = .zap,
        .bulletCount = 3,
        .shootType = .front,
    },
    .{
        .bulletType = .bullet,
        .bulletCount = 5,
        .shootType = .front,
    },
    .{
        .bulletType = .rocket,
        .bulletCount = 5,
        .shootType = .front,
    },
    .{
        .bulletType = .pulse,
        .bulletCount = 5,
        .shootType = .front,
    },
    .{
        .bulletType = .zap,
        .bulletCount = 5,
        .shootType = .front,
    },
    .{
        .bulletType = .bullet,
        .bulletCount = 3,
        .shootType = .burst,
    },
    .{
        .bulletType = .rocket,
        .bulletCount = 3,
        .shootType = .burst,
    },
    .{
        .bulletType = .pulse,
        .bulletCount = 3,
        .shootType = .burst,
    },
    .{
        .bulletType = .zap,
        .bulletCount = 3,
        .shootType = .burst,
    },
    .{
        .bulletType = .bullet,
        .bulletCount = 5,
        .shootType = .burst,
    },
    .{
        .bulletType = .rocket,
        .bulletCount = 5,
        .shootType = .burst,
    },
    .{
        .bulletType = .pulse,
        .bulletCount = 5,
        .shootType = .burst,
    },
    .{
        .bulletType = .zap,
        .bulletCount = 5,
        .shootType = .burst,
    },
};

pub fn shoot(ship: Ship.Ship) anyerror!void {
    const weaponConfig: WeaponConfig = weaponConfigs[@intFromEnum(ship.weapon)];
    const stepX: f32 = Consts.SHIP_SIZE / @as(f32, @floatFromInt(rl.getScreenWidth())) / 10.0;
    const stepY: f32 = Consts.SHIP_SIZE / @as(f32, @floatFromInt(rl.getScreenHeight())) / 10.0;

    try Bullets.add(ship.position.x, ship.position.y - stepY, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 270.0, rl.Color.white, true);

    if (weaponConfig.bulletCount >= 3) {
        if (weaponConfig.shootType == .front) {
            try Bullets.add(ship.position.x - stepX, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 270.0, rl.Color.white, true);
            try Bullets.add(ship.position.x + stepX, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 270.0, rl.Color.white, true);
        } else if (weaponConfig.shootType == .burst) {
            try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 255.0, rl.Color.white, true);
            try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 285.0, rl.Color.white, true);
        } else {
            unreachable;
        }
    }

    if (weaponConfig.bulletCount >= 5) {
        if (weaponConfig.shootType == .front) {
            try Bullets.add(ship.position.x - stepX * 2, ship.position.y + stepY, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 270.0, rl.Color.white, true);
            try Bullets.add(ship.position.x + stepX * 2, ship.position.y + stepY, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 270.0, rl.Color.white, true);
        } else if (weaponConfig.shootType == .burst) {
            try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 240.0, rl.Color.white, true);
            try Bullets.add(ship.position.x, ship.position.y, Consts.BULLET_VELOCITY_X, Consts.BULLET_VELOCITY_Y, weaponConfig.bulletType, 300.0, rl.Color.white, true);
        } else {
            unreachable;
        }
    }
}
