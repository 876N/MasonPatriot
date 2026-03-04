# MasonPatriot

**.NET Assembly Protector**

![Tool](https://i.ibb.co/MDxDyx1q/image.png)

Developed by **ABOLHB**

---

MasonPatriot is a native Win32 protection tool designed to shield .NET assemblies from reverse engineering and unauthorized analysis. The protector wraps your .NET executable inside a fortified native stub that enforces multiple layers of defense before the original payload is ever allowed to execute. Think of it as an armored convoy for your binary — nothing gets through without clearance.

---

![Assembly](https://i.ibb.co/99Sy96Tn/Assembly.png)

After completing a course on Alison I built this project as a practical application of what I learned in x86 Assembly and low level Windows internals

---

## Operational Overview

MasonPatriot operates on a simple but effective doctrine. It takes your .NET assembly as input and produces a hardened native PE executable as output. The original .NET bytecode is encrypted and embedded inside a custom stub written entirely in x86 assembly. At runtime the stub performs a series of environment verification checks before decrypting and launching the payload through the CLR hosting interface. If any check fails the process is terminated immediately with no fallback and no mercy.

The protection pipeline follows this sequence of operations:

**Stage 1 — Payload Ingestion.** The target .NET assembly is read into memory and its integrity is verified. File size and PE headers are validated before proceeding.

**Stage 2 — Encryption.** The raw payload bytes are XOR-encrypted with a 256-byte key that is randomly generated for each protection operation. No two protected binaries share the same key.

**Stage 3 — Stub Assembly.** The encrypted payload along with its key and a protection flags bitmask are injected into the native stub binary. The stub is a minimal PE32 executable compiled with FASM that contains no external dependencies beyond kernel32 and ntdll.

**Stage 4 — Resource Transfer.** Icons and version information from the original assembly are extracted and transplanted into the output binary using the resource update API. The protected file inherits the visual identity of the original.

**Stage 5 — Finalization.** The payload blob is appended after the stub PE and the subsystem field is patched to match the original (GUI or Console). The final binary is written to disk ready for deployment.

---

## Protection Modules

MasonPatriot provides four independent protection modules that can be enabled in any combination depending on your threat model.

**Encrypt** — This is the baseline defense and is always active. The .NET assembly is XOR-encrypted with a unique 256-byte key and cannot be extracted by simply unpacking the PE. The decryption routine runs in native code before the CLR is ever initialized.

**Anti-Debug** — Deploys three detection mechanisms against debugger attachment. First it queries IsDebuggerPresent and CheckRemoteDebuggerPresent through the Win32 API. Then it calls NtQueryInformationProcess with the DebugPort class to detect kernel-level debuggers. Finally it uses a timing-based trap where OutputDebugString is called and the execution time delta is measured — debuggers that process debug strings introduce measurable latency that triggers the kill switch.

**Anti-Dump** — Overwrites the PE headers in memory after the payload has been loaded and the CLR is running. This defeats tools that attempt to dump the process memory and reconstruct a valid PE file. The MZ signature and all header structures are zeroed out making the dump useless for static analysis.

**Anti-VM** — The most comprehensive module. It runs a gauntlet of environment checks designed to identify virtual machines and sandbox environments. The checks are structured as a sequential filter — if any single check triggers the binary terminates through a multi-method kill chain that is extremely difficult to intercept. The detection methods are as follows.

CPUID Vendor String Analysis. The stub executes CPUID with leaf 0x40000000 and inspects the hypervisor vendor string returned in EBX. Known signatures for VMware, KVM, VirtualBox, Xen, and Parallels are matched. If the host is a recognized hypervisor the process is killed.

Registry Reconnaissance. Four registry paths are probed using RegOpenKeyExA under HKEY_LOCAL_MACHINE. These paths correspond to VMware Tools, VirtualBox Guest Additions, the VBoxGuest service driver, and the Windows Sandbox service (intelsbe). If any key exists it confirms virtualization and the process is killed.

Driver File Scanning. The stub checks for the presence of known VM driver files in the system32\drivers directory. Five files are checked covering both VMware (vmmouse.sys and vmhgfs.sys) and VirtualBox (VBoxMouse.sys, VBoxSF.sys, and VBoxGuest.sys). If any driver file exists on disk the process is killed.

Sandbox DLL Injection Detection. Many sandbox environments inject monitoring DLLs into every process. The stub calls GetModuleHandleA for five known sandbox DLLs — SbieDll.dll (Sandboxie), cmdvrt32.dll (Comodo), cuckoomon.dll (Cuckoo and Any.Run), avghookx.dll (AVG), and snxhk.dll (Avast). If any of these modules are loaded in the process address space it confirms sandbox execution and the process is killed. Additionally the stub checks for Wine by looking up the wine_get_version export in ntdll.

Windows Sandbox Identification. The stub reads the USERNAME environment variable and compares the first 8 bytes against "WDAGUtil" which is the default account name used by Windows Sandbox (WDAGUtilityAccount). It also checks for the existence of the C:\Users\WDAGUtilityAccount directory. Either match triggers termination.

Process Count Heuristic. The stub takes a snapshot of all running processes using CreateToolhelp32Snapshot and counts them. Real Windows installations typically have 60 or more processes running. Sandbox environments are stripped down and rarely exceed 20-30 processes. If the count falls below 30 the process is killed.

RDTSC Timing Analysis. The stub executes a calibrated loop of 100000 iterations between two RDTSC readings. On bare metal this loop completes in a predictable number of cycles. Virtual machines and instrumented environments introduce overhead that inflates the cycle count. If the delta exceeds 10000000 cycles the process is killed.

---

## Kill Chain

When any Anti-VM check triggers the binary does not simply call ExitProcess and hope for the best. Sandbox environments frequently hook ExitProcess to prevent monitored processes from terminating. MasonPatriot uses a five-stage escalation kill chain.

First it calls TerminateProcess on its own process handle. This is a more forceful termination that many sandboxes fail to intercept. If that fails it resolves NtTerminateProcess from ntdll and calls it directly at the kernel interface level bypassing any user-mode hooks. If that also fails it falls back to ExitProcess as a third attempt. If all API-based methods are somehow neutralized it performs a deliberate null pointer write (writing to address 0x00000000) which triggers an unrecoverable access violation that crashes the process. As a final guarantee if even the crash handler is intercepted the code enters an infinite loop rendering the process permanently hung and completely unusable.

---

## Build Instructions

MasonPatriot is built entirely with FASM (Flat Assembler). No external toolchains or SDKs are required.

You need FASM installed and accessible in your PATH or placed alongside the build script. The project expects the standard FASM include files for Win32 API definitions.

To build open a command prompt in the build directory and run build.bat. The script compiles the stub first (stub/stub.asm) and then the main GUI application (src/main.asm). Both output PE32 executables targeting 32-bit Windows.

The stub binary is embedded directly inside main.asm as a binary include. After compiling the stub you must ensure the stub binary path referenced in main.asm points to the correct output location. The default build script handles this automatically.

---

## Project Structure

```
MasonShield/
    build/
        build.bat           Build script for FASM
    src/
        main.asm            Main GUI application (Win32 owner-draw UI)
        icon.ico            Application icon
    stub/
        stub.asm            Native protection stub (injected into output)
```

The main application (main.asm) implements the full graphical interface using raw Win32 API calls with no resource files and no dialog templates. Every visual element including buttons, checkboxes, borders, and the title bar is custom drawn through WM_PAINT and WM_DRAWITEM handlers. The color scheme uses a dark palette with accent borders and the interface is designed to feel like a tactical operations console.

The stub (stub.asm) is the runtime component that ships inside every protected binary. It handles decryption, environment verification, CLR initialization, and payload execution. The stub is intentionally minimal with no C runtime and no unnecessary imports to keep the attack surface as small as possible.

---

## System Requirements

The protector GUI runs on Windows 7 and later (32-bit or 64-bit with WOW64). Protected output binaries are native 32-bit PE executables and will run on any Windows version that supports the .NET Framework version required by the original assembly.

FASM version 1.73 or later is required for compilation.

---

## Usage

Launch MasonPatriot.exe. Select your input .NET assembly using the first browse button. Select the output path using the second browse button. Enable the protection modules you want — Encrypt is mandatory and always active while Anti-Debug, Anti-Dump, and Anti-VM are optional. Click PROTECT and monitor the log output at the bottom of the window.

The log will display each stage of the protection process in sequence. If any stage fails you will see an error message with a diagnostic code. A successful operation ends with a completion message and the protected binary is ready at the output path.

---

## Technical Notes

The XOR encryption is not intended to be cryptographically unbreakable. Its purpose is to prevent trivial extraction of the .NET assembly from the binary. Combined with the Anti-Dump module which destroys PE headers at runtime the encryption provides a practical barrier against casual reverse engineering.

The Anti-VM module is designed to have zero false positives on standard physical Windows installations. It does not check the CPUID hypervisor present bit (bit 31 of ECX from CPUID leaf 1) because modern Windows 10 and 11 systems enable Hyper-V by default which sets this bit on real hardware. All detection methods target specific virtualization artifacts that only exist inside actual VMs and sandboxes.

The CLR hosting uses the ICLRMetaHost/ICLRRuntimeInfo/ICLRRuntimeHost interface chain introduced in .NET 4.0. The stub queries for the latest installed runtime version and executes the payload through ExecuteInDefaultAppDomain after loading it from a SafeArray in memory.

---

## License

This project is released as source code for educational and defensive security research purposes. Use it responsibly.

**ABOLHB — MasonPatriot**
