#include "demo/math.hpp"

namespace {

// Имя видно только этому файлу. Такой же abs_int в другом .cpp
// не столкнётся на этапе линковки.
int abs_int(int x) {
    return x < 0 ? -x : x;
}

}

namespace demo {

int add(int a, int b) {
    return a + b;
}

int distance(int a, int b) {
    return abs_int(a - b);
}

}
