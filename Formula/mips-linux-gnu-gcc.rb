# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class MipsLinuxGnuGcc < Formula
  desc "GNU GCC C toolchain for N64 mips-linux-gnu target"
  homepage "https://gcc.gnu.org/"
  url "https://ftp.gnu.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz" 
  sha256 "438fd996826b0c82485a29da03a72d71d6e3541a83ec702df4271f6fe025d24e"
  head "https://gcc.gnu.org/git/gcc.git", branch: "master"

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "mips-linux-gnu-binutils"
  depends_on "make"

  uses_from_macos "zlib"

  # BSD/Darwin sed cannot build gcc, or there will be this error:
  #   xgcc: error: addsf3: No such file or directory
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?format=multiple&id=62097
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66032
  # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=235293
  # Patch to use awk instead
  patch :p0 do
    url "https://gcc.gnu.org/bugzilla/attachment.cgi?id=41380"
    sha256 "8a11bd619c2e55466688e328da00b387d02395c1e8ff4a99225152387a1e60a4"
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
      --enable-languages=all
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
