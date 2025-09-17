# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class MipsLinuxGnuGcc < Formula
    desc "GNU GCC C toolchain for N64 mips-linux-gnu target"
    homepage "https://gcc.gnu.org/"
    url "https://ftpmirror.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.xz"
    mirror "https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.xz"
    sha256 "e2b09ec21660f01fecffb715e0120265216943f038d0e48a9868713e54f06cea"
    head "https://gcc.gnu.org/git/gcc.git", branch: "master"
    
    depends_on "gmp"
    depends_on "isl"
    depends_on "libmpc"
    depends_on "mpfr"
    depends_on "zstd"
    depends_on "make"
    depends_on "mips-linux-gnu-binutils"
    
    uses_from_macos "zlib"
    
    # Branch from the Darwin maintainer of GCC, with a few generic fixes and
    # Apple Silicon support, located at https://github.com/iains/gcc-14-branch
    patch do
        on_macos do
            url "https://raw.githubusercontent.com/Homebrew/formula-patches/575ffcaed6d3112916fed77d271dd3799a7255c4/gcc/gcc-15.1.0.diff"
            sha256 "360fba75cd3ab840c2cd3b04207f745c418df44502298ab156db81d41edf3594"
        end
    end
    
    def version_suffix
        if build.head?
            "HEAD"
        else
            version.to_s.slice(/\d/)
        end
    end
    
    def install
        # ENV.deparallelize  # if your formula fails when building in parallel
        # GCC will suffer build errors if forced to use a particular linker.
        ENV.delete "LD"
        
        args = %W[
        --disable-debug
        --disable-dependency-tracking
        --disable-silent-rules
        --prefix=#{prefix}
        --infodir=#{info}
        --mandir=#{man}
        --libdir=#{lib}/mips-linux-gnu-gcc/#{version_suffix}
        --target=mips-linux-gnu
        --with-arch=vr4300
        --enable-languages=c
        --without-headers
        --with-newlib
        --with-gnu-as=mips-linux-gnu-as
        --with-gnu-ld=mips-linux-gnu-ld
        --enable-checking=release
        --enable-shared
        --enable-shared-libgcc
        --disable-decimal-float
        --disable-gold
        --disable-libatomic
        --disable-libgomp
        --disable-libitm
        --disable-libquadmath
        --disable-libquadmath-support
        --disable-libsanitizer
        --disable-libssp
        --disable-libunwind-exceptions
        --disable-libvtv
        --disable-multilib
        --disable-nls
        --disable-rpath
        --disable-static
        --disable-threads
        --disable-win32-registry
        --enable-lto
        --enable-plugin
        --enable-static
        --without-included-gettext
        --with-system-zlib
        --with-gmp=#{Formula["gmp"].opt_prefix}
        --with-mpfr=#{Formula["mpfr"].opt_prefix}
        --with-mpc=#{Formula["libmpc"].opt_prefix}
        --with-isl=#{Formula["isl"].opt_prefix}
        --with-zstd=#{Formula["zstd"].opt_prefix}
        ]
        
        mkdir "build" do
            system "../configure", *args
            system "gmake"
            system "gmake", "install"
        end
    end
    
    test do
        # `test do` will create, run in and delete a temporary directory.
        #
        # This test will fail and we won't accept that! For Homebrew/homebrew-core
        # this will need to be a test that verifies the functionality of the
        # software. Run the test with `brew test gcc`. Options passed
        # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
        #
        # The installed folder is not in the path, so use the entire path to any
        # executables being tested: `system "#{bin}/program", "do", "something"`.
        system "#{bin}/mips-linux-gnu-gcc", "--version"
    end
end
