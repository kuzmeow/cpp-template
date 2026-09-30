#include "demo/greeter.hpp"

#include <fmt/format.h>

namespace demo {

std::string greet(const std::string& name) {
    return fmt::format("hello, {}", name);
}

}
