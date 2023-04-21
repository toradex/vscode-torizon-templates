#include "appwindow.h"

#include <iostream>

int main(int argc, char **argv)
{
    auto ui = AppWindow::create();

    ui->on_request_increase_value([&]{
        ui->set_counter(ui->get_counter() + 1);
    });

    std::cout << "Hello Torizon!" << std::endl;

    ui->run();
    return 0;
}
