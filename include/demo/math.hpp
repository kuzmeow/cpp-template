#pragma once

namespace demo {

int add(int a, int b);
int distance(int a, int b);

// inline разрешает положить тело прямо в заголовок.
// Компилятор может встроить вызов, а линкер склеит копии в одну.
inline int mul(int a, int b) {
    return a * b;
}

}
