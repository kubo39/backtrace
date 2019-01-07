import std.stdio;
import backtrace;

void main()
{
    trace((Frame frame) {
            auto ip = frame.ip();  // Get instruction pointer.
            auto symbolAddress = frame.symbolAddress();

            // Resolve the instruciotn pointer to a symbol name.
            resolve(ip, (symbol) {
                    writeln(symbol.name.mangled);  // mangled name.
                    writeln(symbol.name.demangled);  // demangled name.
                });
            return true;
        });
}
