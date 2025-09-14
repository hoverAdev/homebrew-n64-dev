class Mips64ElfBinutils < Formula
  desc "GNU binutils for the N64 mip64-elf target"
  homepage "https://www.gnu.org/software/binutils/"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.45.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.45.tar.xz"
  sha256 "c50c0e7f9cb188980e2cc97e4537626b1672441815587f1eab69d2a1bfbef5d2"
  head "git://sourceware.org/git/binutils-gdb.git", branch: "master"

  depends_on "gettext"
  depends_on "texinfo"
  depends_on "mpfr"
  
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
      --disable-silent-rules
      --prefix=#{prefix}
      --includedir=#{include}/mip64-elf-binutils/#{version_suffix}
      --infodir=#{info}/mip64-elf-binutils/#{version_suffix}
      --libdir=#{lib}/mip64-elf-binutils/#{version_suffix}
      --mandir=#{man}/mip64-elf-binutils/#{version_suffix}
      --target=mips64-elf
      --with-arch=vr4300
      --enable-64-bit-bfd
      --enable-plugins
      --enable-shared
      --disable-gold
      --disable-multilib
      --disable-nls
      --disable-rpath
      --disable-static
      --disable-werror
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
    system "#{bin}/mips64-elf-ar", "--version"
    system "#{bin}/mips64-elf-as", "--version"
    system "#{bin}/mips64-elf-ld", "--version"
    system "#{bin}/mips64-elf-objcopy", "--version"
    system "#{bin}/mips64-elf-objdump", "--version"
  end
end
