const rl: type = @import("raylib");

pub const AnimationData: type = struct {
    color: rl.Color = rl.Color.white,
    duration: f32 = 0.0,
    frame: usize = 0,
    frames: usize = 0,
    origin: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    running: bool = false,
    size: f32 = 0.0,
    sizeHalf: f32 = 0.0,
    sourceRect: rl.Rectangle = rl.Rectangle.init(0.0, 0.0, 0.0, 0.0),
    texture: rl.Texture2D = undefined,
    timer: f32 = 0.0,
};

pub const AnimationConfig: type = struct {
    color: rl.Color = rl.Color.white,
    duration: f32 = 0.0,
    frames: usize = 0,
    size: f32 = 0.0,
};

pub fn init(comptime T: type, object: *T, texture: rl.Texture2D, animationConfig: AnimationConfig) void {
    object.animationData.color = animationConfig.color;
    object.animationData.duration = animationConfig.duration;
    object.animationData.frame = 0;
    object.animationData.frames = animationConfig.frames;
    object.animationData.running = false;
    object.animationData.size = animationConfig.size;
    object.animationData.sizeHalf = animationConfig.size * 0.5;
    object.animationData.texture = texture;
    object.animationData.timer = 0.0;

    object.animationData.origin.x = -object.animationData.sizeHalf;
    object.animationData.origin.y = -object.animationData.sizeHalf;

    object.animationData.sourceRect.width = animationConfig.size;
    object.animationData.sourceRect.height = animationConfig.size;
}

pub fn start(comptime T: type, object: *T) void {
    object.animationData.running = true;
}

pub fn stop(comptime T: type, object: *T) void {
    object.animationData.running = false;
}

pub fn reset(comptime T: type, object: *T) void {
    object.animationData.frame = 0;
}

pub fn update(comptime T: type, object: *T, deltaTime: f32) void {
    object.animationData.timer += deltaTime;

    if (object.animationData.timer >= object.animationData.duration) {
        object.animationData.frame = @mod(object.animationData.frame + @as(usize, @intFromFloat(@divFloor(object.animationData.timer, object.animationData.duration))), object.animationData.frames);
        object.animationData.timer = @mod(object.animationData.timer, object.animationData.duration);
    }
}

pub fn draw(comptime T: type, object: *T, x: f32, y: f32, angle: f32) void {
    object.animationData.sourceRect.x = @as(f32, @floatFromInt(object.animationData.frame)) * object.animationData.size;

    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(
        x * @as(f32, @floatFromInt(rl.getScreenWidth())),
        y * @as(f32, @floatFromInt(rl.getScreenHeight())),
        0.0,
    );
    rl.gl.rlRotatef(angle, 0.0, 0.0, 1.0);
    rl.drawTextureRec(
        object.animationData.texture,
        object.animationData.sourceRect,
        object.animationData.origin,
        object.animationData.color,
    );
    rl.gl.rlPopMatrix();
}
