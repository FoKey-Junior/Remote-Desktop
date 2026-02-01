#include "../../include/api/Api.h"
#include <boost/beast/core.hpp>
#include <boost/beast/websocket.hpp>
#include <iostream>
#include <thread>
#include <string>

using tcp = boost::asio::ip::tcp;

void Api::start_server() {
    auto const address = boost::asio::ip::make_address("127.0.0.1");
    auto const port = static_cast<unsigned short>(std::atoi("4000"));

    boost::asio::io_context ioc(1);
    tcp::acceptor acceptor(ioc, {address, port});

    while (true) {
        tcp::socket socket(ioc);
        acceptor.accept(socket);
        std::cout << "server accepted" << std::endl;

        std::thread{[q = std::move(socket)]() mutable {
            boost::beast::websocket::stream<tcp::socket> ws {std::move(q)};
            ws.accept();

            while (true) {
                boost::beast::flat_buffer buffer;
                ws.read(buffer);

                auto out = boost::beast::buffers_to_string(buffer.cdata());
                std::cout << out << std::endl;
            }
        }}.detach();
    }
}