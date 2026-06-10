<div align="center">

<img src="https://github.com/user-attachments/assets/3c12fdea-0b72-405b-bce0-730fbb90fc58" width="180" alt="Logo"/>

# Remote Desktop & API Server

**Remote Desktop** is a remote device management system that combines a cross-platform graphical user interface built with **Qt 6** and a high-performance **C++20** backend powered by the **Boost.Beast** framework.

[![C++](https://img.shields.io/badge/C++-20-00599C?style=flat-square&logo=c%2B%2B)](https://isocpp.org/)
[![Qt](https://img.shields.io/badge/Qt-6-41CD52?style=flat-square&logo=qt)](https://www.qt.io/)
[![CMake](https://img.shields.io/badge/CMake-3.25+-064F8C?style=flat-square&logo=cmake)](https://cmake.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

---

## About the Project

This repository contains the **backend component (REST API)** of the project. 

> **Development Status:** The main Qt client application, which enables you to send commands to your desktop from a smartphone anywhere in the world, is currently in development and will be uploaded soon.

---

## System Architecture

The project is divided into two key components:

### Server-Side (Backend)
* **Core:** Written in pure **C++20** to ensure high performance.
* **REST API:** Built on the lightweight **Crow** framework for routing and handling HTTP requests.
* **Security:** Integrated with **libsodium** for cryptographic protection, secure hashing, and sensitive data storage.
* **Data:** JSON support (native to Crow) for data exchange between the client and the server.

### Client-Side (Frontend / Qt)
* **Interface:** A graphical user interface for authentication, registration, and managing connected devices.
* **Communication:** Interacts with the server via HTTP/REST requests.
* **Cross-Platform Compatibility:** Full support for Linux, macOS, and Windows operating systems.

---

## Tech Stack

| Technology | Purpose |
| :--- | :--- |
| **C++20** | Modern standard ensuring the speed and stability of the server logic |
| **Crow Framework** | Lightweight HTTP server for building C++ REST APIs |
| **Qt 6** | Cross-platform UI development and client application logic |
| **libsodium** | Library for encryption, data protection, and session security |
| **PostgreSQL** | *(Planned)* Relational database for storing users and sessions |

---

## Key Features

* **Secure Authentication:** User registration and login via the Qt application.
* **RESTful Communication:** Well-structured client-server data exchange.
* **Remote Management:** Execution of commands on the target desktop device.
* **Scalability:** The server architecture is designed to handle multiple simultaneous client connections.

---

## Project Goal

To build a secure, flexible remote management ecosystem that is independent of third-party cloud services. The project can be adapted for IoT (Internet of Things) applications, system administration, or exchanging commands between devices in closed networks.
