const std: type = @import("std");
const rl: type = @import("raylib");
const Consts: type = @import("consts.zig");
const Stars: type = @import("stars.zig");
const Bullets: type = @import("bullets.zig");
const Ship: type = @import("ship.zig");

pub fn main() anyerror!u8 {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const gpa_allocator: std.mem.Allocator = gpa.allocator();

    rl.initWindow(Consts.WIDTH, Consts.HEIGHT, "ZigShooter");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    try Stars.init(gpa_allocator, 100);
    defer Stars.deinit();

    try Bullets.init(gpa_allocator);
    defer Bullets.deinit();

    try Ship.init(gpa_allocator);
    defer Ship.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const deltaTime: f32 = rl.getFrameTime();

        rl.clearBackground(rl.Color.black);

        Stars.update(deltaTime);
        Stars.draw();

        Bullets.update(deltaTime);
        Bullets.draw();

        try Ship.processInputs(deltaTime);
        Ship.update(deltaTime);
        Ship.draw();
    }

    return 0;
}
