const std = @import("std");
const stdout = std.io.getStdOut().writer();
/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const socketyzc = @import("socket.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");
const Method = Request.Method;
pub fn main() !void {
    //init socket
    const socket = try socketyzc.Socket.init();
    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    try Request.read_request(connection, buffer[0..buffer.len]);

    const request = Request.parse_request(buffer[0..buffer.len]);
    //check if the method is supported
    if (request.method == Method.GET) {
        if (std.mem.eql(u8, request.uri, "/")) {
            try Response.send_200(connection);
        } else {
            try Response.send_404(connection);
        }
    }
}
