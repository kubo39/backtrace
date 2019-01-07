import std.stdio;
import backtrace;

void main()
{
    trace((Frame frame) {
            auto ip = frame.ip();
            auto symbolAddress = frame.symbolAddress();

            resolve(ip, (symbol) {
                    writeln(symbol.name.mangledName());
                    writeln(symbol.name.demangledName());
                });
            return true;
        });
}
