#include "demo/demo.hpp"

#include <boost/di.hpp>

#include <iostream>
#include <memory>
#include <string>

namespace di = boost::di;

// Контейнер умеет создавать только типы. Свободную функцию ему не передать.
class Speaker {
  public:
    virtual ~Speaker() = default;
    [[nodiscard]] virtual std::string hello(const std::string& name) const = 0;
};

class FmtSpeaker final : public Speaker {
  public:
    [[nodiscard]] std::string hello(const std::string& name) const override {
        return demo::greet(name);
    }
};

// Program не вызывает make_unique и не знает про FmtSpeaker.
// Ему отдают уже готовый Speaker.
class Program {
  public:
    explicit Program(std::unique_ptr<Speaker> speaker) : speaker_(std::move(speaker)) {
    }

    void run(const std::string& name) const {
        using std::cout;
        cout << speaker_->hello(name) << "\n";
        cout << "2 + 3 = " << demo::add(2, 3) << "\n";
        cout << "6 * 7 = " << demo::mul(6, 7) << "\n";
        cout << "distance(2, 5) = " << demo::distance(2, 5) << "\n";
    }

  private:
    std::unique_ptr<Speaker> speaker_;
};

int main(int argc, char** argv) {
    // Единственное место, где сказано, какой Speaker создавать.
    const auto injector = di::make_injector(di::bind<Speaker>.to<FmtSpeaker>());

    const auto* const name = argc > 1 ? argv[1] : "world";
    injector.create<Program>().run(name);
}
