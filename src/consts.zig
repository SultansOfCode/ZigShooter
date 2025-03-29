pub const ASPECT_RATIO: f32 = 720.0 / 1280.0;
pub const HEIGHT: i32 = 900;
pub const WIDTH: i32 = @as(i32, @intFromFloat(@as(f32, @floatFromInt(HEIGHT)) * ASPECT_RATIO));

pub const SHIP_VELOCITY_X: f32 = 0.65;
pub const SHIP_VELOCITY_Y: f32 = 0.65;
pub const SHIP_SHOOT_COOLDOWN: f32 = 0.025;
pub const SHIP_SIZE: f32 = 48.0;
pub const SHIP_SIZE_HALF: f32 = SHIP_SIZE * 0.5;

pub const BULLET_VELOCITY_X: f32 = 1.0;
pub const BULLET_VELOCITY_Y: f32 = 1.0;
pub const BULLET_SIZE: f32 = 32.0;
pub const BULLET_SIZE_HALF: f32 = BULLET_SIZE * 0.5;
