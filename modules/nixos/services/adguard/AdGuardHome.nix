{
  theme = "auto";
  dns = {
    port = 53;
    anonymize_client_ip = false;
    ratelimit = 20;
    ratelimit_subnet_len_ipv4 = 24;
    ratelimit_subnet_len_ipv6 = 56;
    ratelimit_whitelist = [ ];
    refuse_any = true;
    upstream_dns = [
      "#https://dns.cloudflare.com/dns-query"
      "https://dns10.quad9.net/dns-query"
      "#tls://1dot1dot1dot1.cloudflare-dns.com"
    ];
    upstream_dns_file = "";
    bootstrap_dns = [
      "9.9.9.10"
      "149.112.112.10"
      "2620:fe::10"
      "2620:fe::fe:10"
    ];
    fallback_dns = [ ];
    upstream_mode = "parallel";
    fastest_timeout = "1s";
    allowed_clients = [ ];
    disallowed_clients = [ ];
    blocked_hosts = [
      "version.bind"
      "id.server"
      "hostname.bind"
    ];
    trusted_proxies = [
      "127.0.0.0/8"
      "::1/128"
    ];
    cache_enabled = true;
    cache_size = 4194304;
    cache_ttl_min = 0;
    cache_ttl_max = 0;
    cache_optimistic = false;
    cache_optimistic_answer_ttl = "30s";
    cache_optimistic_max_age = "12h";
    bogus_nxdomain = [ ];
    aaaa_disabled = false;
    enable_dnssec = true;
    edns_client_subnet = {
      custom_ip = "";
      enabled = true;
      use_custom = false;
    };
    max_goroutines = 300;
    handle_ddr = true;
    ipset = [ ];
    ipset_file = "";
    bootstrap_prefer_ipv6 = false;
    upstream_timeout = "10s";
    private_networks = [ ];
    use_private_ptr_resolvers = false;
    local_ptr_upstreams = [ ];
    use_dns64 = false;
    dns64_prefixes = [ ];
    serve_http3 = false;
    use_http3_upstreams = false;
    serve_plain_dns = true;
    hostsfile_enabled = true;
    pending_requests = {
      enabled = true;
    };
  };
  tls = {
    enabled = false;
    server_name = "holypenguin.net";
    force_https = false;
    port_https = 443;
    port_dns_over_tls = 853;
    port_dns_over_quic = 853;
    port_dnscrypt = 0;
    dnscrypt_config_file = "";
    certificate_path = "";
    private_key_path = "";
    strict_sni_check = false;
  };
  querylog = {
    dir_path = "";
    ignored = [ ];
    interval = "2160h";
    size_memory = 1000;
    enabled = true;
    ignored_enabled = false;
    file_enabled = true;
  };
  statistics = {
    dir_path = "";
    ignored = [ ];
    interval = "2160h";
    enabled = true;
    ignored_enabled = false;
  };
  filters = [
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
      name = "AdGuard DNS filter";
      id = 1;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
      name = "AdAway Default Blocklist";
      id = 2;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_24.txt";
      name = "1Hosts (Lite)";
      id = 1679844511;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_38.txt";
      name = "1Hosts (mini)";
      id = 1679844512;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt";
      name = "HaGeZi Personal Black & White";
      id = 1679844513;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
      name = "Dan Pollock's List";
      id = 1679844514;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_32.txt";
      name = "The NoTracking blocklist";
      id = 1679844515;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt";
      name = "OISD Blocklist Basic";
      id = 1679844516;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
      name = "Steven Black's List";
      id = 1679844517;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";
      name = "Peter Lowe's Blocklist";
      id = 1679844518;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
      name = "OISD Blocklist Full";
      id = 1679844519;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_23.txt";
      name = "WindowsSpyBlocker - Hosts spy rules";
      id = 1679844520;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";
      name = "Perflyst and Dandelion Sprout's Smart-TV Blocklist";
      id = 1679844521;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
      name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
      id = 1679844522;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
      name = "NoCoin Filter List";
      id = 1679844523;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
      name = "Dandelion Sprout's Anti-Malware List";
      id = 1679844524;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt";
      name = "Scam Blocklist by DurableNapkin";
      id = 1679844525;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt";
      name = "Stalkerware Indicators List";
      id = 1679844526;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
      name = "The Big List of Hacked Malware Web Sites";
      id = 1679844527;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
      name = "Malicious URL Blocklist (URLHaus)";
      id = 1679844528;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts";
      name = "Fakenews";
      id = 1679845498;
    }
    {
      enabled = true;
      url = "https://raw.github.com/notracking/hosts-blocklists/master/hostnames.txt";
      name = "Tracking";
      id = 1679845500;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt";
      name = "Tracking";
      id = 1679845501;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Streaming";
      name = "Fakeshop";
      id = 1679845502;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/notserious";
      name = "Fakeshop";
      id = 1679845503;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Monstanner/DuckDuckGo-Fakeshops-Blocklist/main/Blockliste";
      name = "Fakeshop";
      id = 1679845504;
    }
    {
      enabled = true;
      url = "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/fake.txt";
      name = "Fakeshop";
      id = 1679845505;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/easylist";
      name = "Werbung";
      id = 1679845506;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/spam.mails";
      name = "Werbung";
      id = 1679845507;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt";
      name = "Werbung";
      id = 1679845508;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/Easyprivacy.txt";
      name = "Werbung";
      id = 1679845509;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/Easylist.txt";
      name = "Werbung";
      id = 1679845510;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/Prigent-Ads.txt";
      name = "Werbung";
      id = 1679845511;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/AdguardDNS.txt";
      name = "Werbung";
      id = 1679845512;
    }
    {
      enabled = true;
      url = "https://adaway.org/hosts.txt";
      name = "Werbung";
      id = 1679845513;
    }
    {
      enabled = true;
      url = "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt";
      name = "Werbung";
      id = 1679845514;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts";
      name = "Werbung";
      id = 1679845515;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/light.txt";
      name = "Werbung";
      id = 1679845516;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/Germany.txt";
      name = "German Ad";
      id = 1679845517;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CombinedBlacklists/CombinedBlackLists.txt";
      name = "Big Adlist";
      id = 1679845518;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CombinedBlacklists/DeathbybandaidList.txt";
      name = "Comunity";
      id = 1679845519;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/youtubelist.txt";
      name = "Youtube";
      id = 1679845520;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/Admiral.txt";
      name = "Werbung";
      id = 1679845521;
    }
    {
      enabled = true;
      url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext";
      name = "Werbung";
      id = 1679845522;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts";
      name = "Werbung";
      id = 1679845523;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts";
      name = "Werbung";
      id = 1679845524;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts";
      name = "Tracking";
      id = 1679845525;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt";
      name = "Tracking";
      id = 1679845526;
    }
    {
      enabled = true;
      url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt";
      name = "Tracking";
      id = 1679845527;
    }
    {
      enabled = true;
      url = "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt";
      name = "Tracking";
      id = 1679845528;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt";
      name = "Tracking";
      id = 1679845529;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt";
      name = "Tracking";
      id = 1679845530;
    }
    {
      enabled = true;
      url = "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt";
      name = "Tracking";
      id = 1679845531;
    }
    {
      enabled = true;
      url = "https://hostfiles.frogeye.fr/multiparty-trackers-hosts.txt";
      name = "Tracking";
      id = 1679845532;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Kees1958/W3C_annual_most_used_survey_blocklist/6b8c2411f22dda68b0b41757aeda10e50717a802/TOP_EU_US_Ads_Trackers_HOST";
      name = "Tracking";
      id = 1679845533;
    }
    {
      enabled = true;
      url = "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser";
      name = "Miner";
      id = 1679845534;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt";
      name = "Maleware";
      id = 1679845535;
    }
    {
      enabled = true;
      url = "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt";
      name = "Maleware";
      id = 1679845536;
    }
    {
      enabled = true;
      url = "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt";
      name = "Maleware";
      id = 1679845537;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/Prigent-Crypto.txt";
      name = "Maleware";
      id = 1679845538;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts";
      name = "Maleware";
      id = 1679845539;
    }
    {
      enabled = true;
      url = "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt";
      name = "Maleware";
      id = 1679845540;
    }
    {
      enabled = true;
      url = "https://phishing.army/download/phishing_army_blocklist_extended.txt";
      name = "Maleware";
      id = 1679845541;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/RPiList-Malware.txt";
      name = "Maleware";
      id = 1679845542;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/RPiList-Phishing.txt";
      name = "Tracking";
      id = 1679845543;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt";
      name = "Maleware";
      id = 1679845544;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts";
      name = "Maleware";
      id = 1679845545;
    }
    {
      enabled = true;
      url = "https://urlhaus.abuse.ch/downloads/hostfile/";
      name = "Maleware";
      id = 1679845546;
    }
    {
      enabled = true;
      url = "https://malware-filter.gitlab.io/malware-filter/phishing-filter-hosts.txt";
      name = "Maleware";
      id = 1679845547;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/Prigent-Malware.txt";
      name = "Maleware";
      id = 1679845548;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/tg12/pihole-phishtank-list/master/list/phish_domains.txt";
      name = "Maleware";
      id = 1679845549;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/HorusTeknoloji/TR-PhishingList/master/url-lists.txt";
      name = "Maleware";
      id = 1679845550;
    }
    {
      enabled = true;
      url = "https://v.firebog.net/hosts/static/w3kbl.txt";
      name = "Werbung";
      id = 1679845551;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt";
      name = "AWAvenue Ads Rule";
      id = 1730050215;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
      name = "AdGuard DNS Popup Hosts filter";
      id = 1730050216;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_60.txt";
      name = "HaGeZi's Xiaomi Tracker Blocklist";
      id = 1730050217;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt";
      name = "uBlock₀ filters – Badware risks";
      id = 1730050218;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_46.txt";
      name = "HaGeZi's Anti-Piracy Blocklist";
      id = 1730050219;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/popupads.txt";
      name = "Pop Up";
      id = 1730050220;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt";
      name = "HaGeZi's Pro++ Blocklist";
      id = 1737826069;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt";
      name = "HaGeZi's Pro Blocklist";
      id = 1737826070;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_49.txt";
      name = "HaGeZi's Ultimate Blocklist";
      id = 1737826071;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt";
      name = "Dandelion Sprout's Anti Push Notifications";
      id = 1737826072;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_45.txt";
      name = "HaGeZi's Allowlist Referral";
      id = 1737826073;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_61.txt";
      name = "HaGeZi's Samsung Tracker Blocklist";
      id = 1737826074;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_52.txt";
      name = "HaGeZi's Encrypted DNS/VPN/TOR/Proxy Bypass";
      id = 1737826075;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_57.txt";
      name = "ShadowWhisperer's Dating List";
      id = 1737826076;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_47.txt";
      name = "HaGeZi's Gambling Blocklist";
      id = 1737826077;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_63.txt";
      name = "HaGeZi's Windows/Office Tracker Blocklist";
      id = 1737826078;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_62.txt";
      name = "Ukrainian Security Filter";
      id = 1737826079;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_55.txt";
      name = "HaGeZi's Badware Hoster Blocklist";
      id = 1737826080;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_56.txt";
      name = "HaGeZi's The World's Most Abused TLDs";
      id = 1737826081;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt";
      name = "HaGeZi's Threat Intelligence Feeds";
      id = 1737826082;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt";
      name = "Phishing Army";
      id = 1737826083;
    }
    {
      enabled = true;
      url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_42.txt";
      name = "ShadowWhisperer's Malware List";
      id = 1737826084;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/ph00lt0/blocklist/master/blocklist.txt";
      name = "Blocklist";
      id = 1737826085;
    }
  ];
  whitelist_filters = [
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt";
      name = "Whitelist";
      id = 1679845499;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/hl2guide/AdGuard-Home-Whitelist/main/whitelist.txt";
      name = "hl2guide";
      id = 1694142222;
    }
    {
      enabled = true;
      url = "https://raw.githubusercontent.com/Svenum/dns-lists/refs/heads/main/whitelist.txt";
      name = "My Shit";
      id = 1755745297;
    }
  ];
  user_rules = [
    "@@||eic.homeprv.lgtvcommon.com^$important"
    "@@||de.ibs.lgappstv.com^$important"
    "@@||eis.de^$important"
    "@@||wp.com^$important"
    "@@||eic.recommend.lgtvcommon.com^$important"
    "@@||eic.cdpbeacon.lgtvcommon.com^$important"
    "@@||lgtvonline.lge.com^$important"
    "@@||eic.service.lgtvcommon.com^$important"
    "@@||eic.cdpsvc.lgtvcommon.com^$important"
    "@@||de.ad.lgsmartad.com^$important"
    "@@||api.eu-west-1.aiv-delivery.net^$important"
    "@@||eic.netflixvoice.lgtvcommon.com^$important"
    "@@||protonvpn.net^$important"
    "@@||shop.kapten-son.com^"
    "@@||share.google^$important"
    "@@||gameloft.com^"
    "@@||cdn.aqara.com^$important"
    "@@||track-ger.aqara.com^$important"
    "@@||sdk.iad-05.braze.com^$important"
    "@@||storage.organise.photos^$important"
    "@@||js-cdn.dynatrace.com^$important"
    "@@||www.rnd.de^$important"
    "@@||authentik.error-reporting.a7k.io^$important"
    "@@||browser-intake-datadoghq.com^$important"
    "@@||dqs14963.live.dynatrace.com^$important"
    "@@||logging.albelli.com^$important"
    "@@||imageeditservice.ebt.infra.photos^$important"
    "@@||events.launchdarkly.com^$important"
    "@@||ads.mozilla.org^$important"
    "@@||merino.services.mozilla.com^$important"
    "@@||errors.authjs.dev^$important"
    "@@||locationhistory-pa.googleapis.com^$important"
    ""
  ];
  filtering = {
    blocking_ipv4 = "";
    blocking_ipv6 = "";
    blocked_services = {
      schedule = {
        time_zone = "UTC";
      };
      ids = [
        "9gag"
        "bilibili"
        "dailymotion"
        "deezer"
        "douban"
        "hbomax"
        "hulu"
        "iqiyi"
        "kakaotalk"
        "lazada"
        "line"
        "mail_ru"
        "ok"
        "onlyfans"
        "qq"
        "rakuten_viki"
        "roblox"
        "shopee"
        "skype"
        "telegram"
        "tinder"
        "viber"
        "vimeo"
        "vk"
        "voot"
        "wechat"
        "weibo"
        "zhihu"
        "bigo_live"
        "betway"
        "betfair"
        "betano"
        "discoveryplus"
        "plenty_of_fish"
        "xiaohongshu"
        "wizz"
      ];
    };
    protection_disabled_until = null;
    safe_search = {
      enabled = false;
      bing = false;
      duckduckgo = false;
      ecosia = false;
      google = false;
      pixabay = false;
      yandex = false;
      youtube = false;
    };
    blocking_mode = "default";
    parental_block_host = "family-block.dns.adguard.com";
    safebrowsing_block_host = "standard-block.dns.adguard.com";
    rewrites = [
      {
        domain = "pr-epson.intra.holypenguin.net";
        answer = "172.18.0.148";
        enabled = true;
      }
      {
        domain = "pr-hp.intra.holypenguin.net";
        answer = "172.18.0.152";
        enabled = true;
      }
      {
        domain = "pi.holypenguin.net";
        answer = "172.16.0.12";
        enabled = true;
      }
      {
        domain = "*.pi.holypenguin.net";
        answer = "172.16.0.5";
        enabled = true;
      }
      {
        domain = "pi5.holypenguin.net";
        answer = "172.16.0.13";
        enabled = true;
      }
      {
        domain = "garden.holypenguin.net";
        answer = "garden.holypenguin.net";
        enabled = true;
      }
      {
        domain = "notes.holypenguin.net";
        answer = "notes.holypenguin.net";
        enabled = true;
      }
      {
        domain = "burpee.holypenguin.net";
        answer = "burpee.holypenguin.net";
        enabled = true;
      }
    ];
    safebrowsing_cache_size = 1048576;
    safesearch_cache_size = 1048576;
    parental_cache_size = 1048576;
    cache_time = 30;
    filters_update_interval = 12;
    blocked_response_ttl = 10;
    filtering_enabled = true;
    rewrites_enabled = true;
    parental_enabled = false;
    safebrowsing_enabled = true;
    protection_enabled = false;
  };
  clients = {
    runtime_sources = {
      whois = true;
      arp = true;
      rdns = true;
      dhcp = true;
      hosts = true;
    };
    persistent = [ ];
  };
  log = {
    enabled = true;
    file = "";
    max_backups = 0;
    max_size = 100;
    max_age = 3;
    compress = false;
    local_time = false;
    verbose = false;
  };
}
