module Stampede
  module Runner::Daemonization
    def daemonize!
      rd, wr = IO.pipe
      if fork
        wr.close
        setup_parent rd
      else
        rd.close
        setup_daemon wr
      end
    end

    private

    def setup_daemon(pipe)
      ::Process.setsid
      Dir.chdir "/"
      File.umask 0000

      $stdin.reopen "/dev/null"
      $stdout.reopen "/dev/null"
      $stderr.reopen $stdout

      pipe.syswrite($$.to_s)
      pipe.close rescue nil
    end

    def setup_parent(pipe)
      master_pid = (pipe.readpartial(16) rescue nil).to_i
      unless master_pid > 1
        warn "Daemon process died, check log for details."
        exit! 1
      end
      exit 0
    end
  end
end
