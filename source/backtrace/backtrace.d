module backtrace.backtrace;

import core.stdc.stdint;

version(linux):

extern (C)
{
    // Stolen from rt.unwind.

    alias _Unwind_Ptr = uintptr_t;
    alias _Unwind_Reason_Code = int;
    enum : _Unwind_Reason_Code
    {
        _URC_NO_REASON = 0,
        _URC_FAILURE = 9,  // used only by ARM EABI
    }

    alias _Unwind_Trace_Fn = _Unwind_Reason_Code function(_Unwind_Context*, void*);

    struct _Unwind_Context;

    _Unwind_Ptr _Unwind_GetIPInfo(_Unwind_Context* context, int*);
    void* _Unwind_FindEnclosingFunction(void* ip);
    _Unwind_Reason_Code _Unwind_Backtrace(_Unwind_Trace_Fn, void*);

    _Unwind_Reason_Code _trace_fn(_Unwind_Context* context, void* arg)
    {
        auto cb = cast(bool function(Frame)) arg;
        Frame frame = Frame(context);
        return cb(frame) ? _URC_NO_REASON : _URC_FAILURE;
    }
}

struct Frame
{
    _Unwind_Context* ctx;

    /* Get instruction pointer.
     */
    void* ip() @property
    {
        int ip_before_insn;
        // The instruction pointer must not be decremented from a signal handler frame.
        // (also see etc.linux.memoryerror and rt.dwarfeh).
        // So use _Unwind_GetIPInfo here.
        auto ip = _Unwind_GetIPInfo(ctx, &ip_before_insn);
        if (!ip_before_insn) --ip;
        return cast(void*) ip;
    }

    void* symbolAddress() @property
    {
        // According to Rust's backtrace-rs, this won't work well
        // on macOS.
        return _Unwind_FindEnclosingFunction(this.ip());
    }
}

void trace(bool function(Frame) cb)
{
    pragma(inline, true);
    _Unwind_Backtrace(&_trace_fn, cast(void*) cb);
}
