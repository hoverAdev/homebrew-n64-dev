class MipsLinuxGnuBinutils < Formula
  desc "GNU binutils for the N64 mips-linux-gnu target"
  homepage "https://www.gnu.org/software/binutils/"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.45.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.45.tar.xz"
  sha256 "c50c0e7f9cb188980e2cc97e4537626b1672441815587f1eab69d2a1bfbef5d2"
  head "git://sourceware.org/git/binutils-gdb.git", branch: "master"

  depends_on "gettext"
  depends_on "texinfo"
  depends_on "zstd"
  
  uses_from_macos "zlib"

  def version_suffix
    if build.head?
      "HEAD"
    else
      version.to_s.slice(/\d/)
    end
  end

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --enable-deterministic-archives
      --prefix=#{prefix}
      --includedir=#{include}/mips-linux-gnu-binutils/#{version_suffix}
      --infodir=#{info}/mips-linux-gnu-binutils/#{version_suffix}
      --libdir=#{lib}/mips-linux-gnu-binutils/#{version_suffix}
      --mandir=#{man}/mips-linux-gnu-binutils/#{version_suffix}
      --target=mips-linux-gnu
      --with-arch=vr4300
      --disable-werror
      --enable-interwork
      --enable-multilib
      --enable-64-bit-bfd
      --enable-plugins
      --enable-targets=all
      --with-zstd
      --with-system-zlib
      --disable-nls
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"
      system "make", "install"
    end
                          
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test binutils`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "#{bin}/mips-linux-gnu-ar", "--version"
    system "#{bin}/mips-linux-gnu-as", "--version"
    system "#{bin}/mips-linux-gnu-ld", "--version"
    system "#{bin}/mips-linux-gnu-objcopy", "--version"
    system "#{bin}/mips-linux-gnu-objdump", "--version"
  end
end
