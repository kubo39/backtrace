module backtrace.symbolize;

import core.demangle;
import core.stdc.string;
import core.sys.linux.dlfcn;

struct SymbolName
{
private:
    char[] _mangled;
    char[] _demangled;

public:
    this(char* ptr, size_t len)
    {
        enum SIZE = 1000; // FIXME: guess 1000 is enough, maybe optimise better..
        _mangled = new char[len];
        memcpy(_mangled.ptr, ptr, len);
        _demangled = new char[SIZE];
        demangle(_mangled, _demangled);
    }

    /* Returns demangled symbol.
     */
    string demangled() @property
    {
        return cast(string) _demangled;
    }

    /* Returns mangled(raw) symbol.
     */
    string mangled() @property
    {
        return cast(string) _mangled;
    }
}

struct Symbol
{
    Dl_info info;

    SymbolName* name() @property
    {
        if (this.info.dli_sname is null)
            return null;
        auto ptr = cast(char*) this.info.dli_sname;
        auto len = strlen(this.info.dli_sname);
        return new SymbolName(ptr, len);
    }

    void* addr() @property
    {
        return this.info.dli_saddr;
    }
}

/* Resolve an address to symbol.
 */
void resolve(void* addr, void function(Symbol) cb)
{
    Symbol symbol;

    // Though use dladdr() here now, but according to Rust's
    // backtrace-rs, dladdr() is fairly unreliable on linux.
    // And libbacktrace would be better choise.
    if (dladdr(addr, &symbol.info) != 0)
        cb(symbol);
}
