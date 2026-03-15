{ pkgs, lib, ... }:
{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.rust-mode
    ];
    extraConfig = ''
      (load-theme 'modus-vivendi t)

      ;Regular stuff
      (setq compilation-scroll-output t)

      ;Rust mode
      (require 'rust-mode)
      (setq rust-format-on-save t)
      (setq rust-mode-treesitter-derive t)
      (add-hook 'rust-mode-hook #'eglot-ensure)
      (add-hook 'rust-mode-hook #'prettify-symbols-mode)
      (add-hook 'rust-mode-hook (lambda () (setq indent-tabs-mode nil)))
    '';
  };
}
