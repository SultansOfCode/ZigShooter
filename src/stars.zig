const std: type = @import("std");
const rl: type = @import("raylib");

const rand: std.Random = std.crypto.random;

const Star: type = struct {
    position: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    velocity: rl.Vector2 = rl.Vector2.init(0.0, 0.0),
    color: rl.Color = rl.Color.white,

    fn resetRandom(self: *Star) void {
        const x: f32 = rand.float(f32);
        const y: f32 = rand.float(f32);
        const vx: f32 = rand.float(f32) * 0.5 + 0.2;
        const vy: f32 = rand.float(f32) * 0.5 + 0.2;

        self.position.x = x;
        self.position.y = y;

        self.velocity.x = vx;
        self.velocity.y = vy;

        const brightness: u8 = rand.intRangeAtMost(u8, 50, 255);

        self.color = rl.Color.init(brightness, brightness, brightness, 255);
    }

    pub fn init(x: f32, y: f32, vx: f32, vy: f32, color: rl.Color) Star {
        return Star{
            .position = rl.Vector2.init(x, y),
            .velocity = rl.Vector2.init(vx, vy),
            .color = color,
        };
    }

    pub fn initRandom() Star {
        var star: Star = Star{};

        star.resetRandom();

        return star;
    }

    pub fn update(self: *Star, deltaTime: f32) void {
        self.position.x += self.velocity.x * deltaTime;
        self.position.y += self.velocity.y * deltaTime;

        if (self.position.x < 0 or self.position.x >= 1.0 or self.position.y < 0 or self.position.y >= 1.0) {
            self.resetRandom();

            self.position.y = 0.0;
            self.velocity.x = 0.0;
        }
    }

    pub fn draw(self: Star) void {
        const position: rl.Vector2 = rl.Vector2.init(
            self.position.x * @as(f32, @floatFromInt(rl.getScreenWidth())),
            self.position.y * @as(f32, @floatFromInt(rl.getScreenHeight())),
        );

        rl.drawPixelV(position, self.color);
    }
};

var stars: std.ArrayList(Star) = undefined;

pub fn init(allocator: std.mem.Allocator, quantity: usize) anyerror!void {
    stars = std.ArrayList(Star).init(allocator);

    for (0..quantity) |_| {
        var star: Star = Star.initRandom();

        star.velocity.x = 0.0;

        try stars.append(star);
    }
}

pub fn deinit() void {
    stars.deinit();
}

pub fn update(deltaTime: f32) void {
    for (stars.items) |*star| {
        star.update(deltaTime);
    }
}

pub fn draw() void {
    for (stars.items) |star| {
        star.draw();
    }
}
