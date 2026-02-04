#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/asio.hpp>
#include <iostream>

#include "../../include/api/Api.hpp"


namespace beast = boost::beast;
namespace http  = beast::http;
namespace net   = boost::asio;
using tcp       = net::ip::tcp;

void Api::start_server(int port_) {
    port = port_;

    try {
        net::io_context ioc;

        tcp::acceptor acceptor{
            ioc,
            {tcp::v4(), 8080}
        };

        std::cout << "HTTP server started on port " << port << std::endl;

        for (;;) {
            tcp::socket socket{ioc};
            acceptor.accept(socket);

            beast::flat_buffer buffer;
            http::request<http::string_body> req;
            http::read(socket, buffer, req);

            http::response<http::string_body> res{
                http::status::ok,
                req.version()
            };

            res.set(http::field::server, "Boost.Beast");
            res.set(http::field::content_type, "text/plain");
            res.body() = "server working";
            res.prepare_payload();

            http::write(socket, res);
            socket.shutdown(tcp::socket::shutdown_send);
        }
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << '\n';
    }
}
