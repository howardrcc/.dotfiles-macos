{ pkgs, ... }:

# R environment for the dwhr R/Shiny dashboard package and its example apps
# (~/workspace/dwhr).
#
# Bundles every CRAN dep used by:
#   - dwhr's DESCRIPTION Imports
#   - inst/examples/15PdfShowcase
#   - inst/examples/16D3Sankey
#   - inst/examples/17MunicipalShowcase
#
# All listed packages were verified present in nixpkgs-unstable. The one
# exception is `spDataLarge` (used by 17MunicipalShowcase/leaflet.R), which
# is not in CRAN/nixpkgs and must be installed once into the user library:
#
#     R -e 'remotes::install_github("Nowosad/spDataLarge")'
#
# After `darwin-rebuild switch`, `R` and `Rscript` on PATH come from this
# wrapper. The CRAN binary R at /usr/local/bin/R is not removed — Nix's R
# is added earlier in PATH and shadows it. Uninstall the CRAN R when you're
# confident this env is solid.

let
  rPackages = with pkgs.rPackages; [
    # dwhr DESCRIPTION Imports
    shiny
    shinyjs
    shinyjqui
    data_table        # data.table — Nix replaces dots with underscores
    digest
    RODBC
    scales
    DT
    highcharter
    rlist
    checkmate
    sparkline
    DBI
    odbc

    # Shared across examples
    magrittr

    # 15PdfShowcase
    knitr
    kableExtra
    stlplus
    future
    shinytest
    webshot
    htmlwidgets
    zoo

    # 16D3Sankey
    networkD3
    shinycssloaders

    # 17MunicipalShowcase
    ggplot2
    tidyverse
    Cairo
    leaflet
    terra
    sf
    tmaptools
    cbsodataR
    readxl
    gapminder
    gganimate
    widgetframe
    dplyr
    akima             # archived from CRAN; nixpkgs still ships it

    # Dev tooling
    devtools
    roxygen2
    testthat
    rcmdcheck
    remotes
  ];

  rEnv = pkgs.rWrapper.override {
    packages = rPackages;
  };
in
{
  environment.systemPackages = [
    rEnv

    # Build tools — needed for any source compiles done from inside R
    # (e.g. spDataLarge from GitHub, or other CRAN packages without
    # binary aarch64-darwin builds).
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.gcc

    # LaTeX is provided by Yihui Xie's TinyTeX (R-managed at ~/Library/TinyTeX),
    # not nixpkgs. Bootstrap with: R -e 'tinytex::install_tinytex()'.
    # TinyTeX auto-installs missing .sty files on first compile, which
    # nixpkgs' read-only texlive cannot — important for the kableExtra
    # / Sweave templates in inst/examples/15PdfShowcase/*.Rnw.
    # pandoc is already in modules/darwin/packages.nix
  ];
}
