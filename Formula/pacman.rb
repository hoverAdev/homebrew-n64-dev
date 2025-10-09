# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Pacman < Formula
    desc "A simple library-based package manager."
    homepage "https://pacman.archlinux.page"
    url "https://gitlab.archlinux.org/pacman/pacman/-/archive/v7.0.0/pacman-v7.0.0.tar.gz"
    sha256 "ef08f258cb3e0885c5884ad43fb6cff0e9c327ed33024d79d03555f99c583744"
    head "https://gitlab.archlinux.org/pacman/pacman.git", branch: "master"

    depends_on "bash"
    depends_on "libarchive"
    depends_on "gpgme"
    depends_on "gettext"

    depends_on "meson"
    depends_on "cmake"
    depends_on "ninja"

    uses_from_macos "true"

    def version_suffix
        if build.head?
        "HEAD"
        else
        version.to_s.slice(/\d/)
        end
    end

    def install
        ENV.append "LDFLAGS", "-lintl"

        mkdir "build" do
            system "meson", "setup", ".", "..",
                "--buildtype", "release",
                "--prefix", prefix,
                "--infodir", info,
                "--mandir", man,
                "--libdir", lib,
                "--sysconfdir", etc,
                "--localstatedir", var
            system "ninja"
            system "ninja", "install"
        end
    end
  
    def post_install
        # Set up pacman RootDir
        (var/"pacman").mkpath
        (var/"pacman/pkg").mkpath
        (var/"pacman/var").mkpath
        (var/"pacman/var/lib/pacman").mkpath

        inreplace etc/"pacman.conf" do |s|
            s.gsub!(/^#?RootDir\s*=.*$/, "RootDir = #{var}/pacman")
            s.gsub!(/^#?DBPath\s*=.*$/, "DBPath = #{var}/pacman/var/lib/pacman")

            # Praying this stupid vibe code works (i don't like vibe coding but i don't know ruby)
            s.gsub!(/\z/, "\n[core]\nSigLevel = Required\nServer = https://mirror.rackspace.com/archlinux/core/os/x86_64/\n")
            s.gsub!(/\z/, "\n[extra]\nSigLevel = Optional\nServer = https://mirror.rackspace.com/archlinux/extra/os/x86_64/\n")
        end
       
        ohai "Pacman will install packages into #{HOMEBREW_PREFIX}/pacman."
        puts "This location is isolated to avoid conflicts with system or Homebrew packages."
        puts "Pacman is not linked into your PATH by default."
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
        system "#{bin}/pacman", "--version"
    end
end
