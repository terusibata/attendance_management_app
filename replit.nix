{ pkgs, ... }: {
    
	deps = [
        pkgs.tzdata
        pkgs.ruby_3_1
        pkgs.rubyPackages_3_1.nokogiri
        pkgs.rubyPackages_3_1.sassc
        pkgs.solargraph
        pkgs.rufo
        pkgs.sqlite
	];

    environment.variables.TZDIR = "/etc/zoneinfo";
    environment.variables.TZ = "Asia/Tokyo";

    environment.etc.localtime.source = "${pkgs.tzdata}/share/zoneinfo/Asia/Tokyo";

    environment.etc.zoneinfo.source = "${pkgs.tzdata}/share/zoneinfo";
}