#include "../../include/api/Api.h"
#include <boost/beast/core.hpp>
#include <boost/beast/websocket.hpp>
#include <iostream>
#include <string>
#include <thread>

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
    }
}