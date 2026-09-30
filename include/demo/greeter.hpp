#pragma once

#include <string>

namespace demo {

// Здесь только объявление. Тело функции лежит в src/greeter.cpp.
// Если вписать тело в заголовок без inline, линкер увидит его
// в каждом .cpp, который этот заголовок подключил, и откажется собирать.
std::string greet(const std::string& name);

}
