module VersionEye
  module LicenseTrait

    def name_substitute
      return 'unknown' if name.to_s.empty?

      tmp_name = name.gsub(/The /i, "").gsub(" - ", " ").gsub(", ", " ").strip

      return 'MIT' if mit_match( tmp_name )
      return 'Ruby' if ruby_match( tmp_name )

      return 'BSD 3-clause Revised License'  if bsd_3_clause_match( tmp_name )
      return 'BSD style' if bsd_style_match( tmp_name )
      return 'New BSD' if new_bsd_match( tmp_name )
      return 'BSD' if bsd_match( tmp_name )

      return 'CDDL' if cddl_match( tmp_name )
      return 'GPL-2.0' if gpl_20_match( tmp_name )

      return 'Common Public License 1.0' if cpl_10_match( tmp_name )

      return 'MPL-1.0'  if mpl_10_match( tmp_name )
      return 'MPL-1.1'  if mpl_11_match( tmp_name )
      return 'MPL-2.0'  if mpl_20_match( tmp_name )

      return 'LGPL-2.0'  if lgpl_20_match( tmp_name )
      return 'LGPL-2.1'  if lgpl_21_match( tmp_name )
      return 'LGPL-3.0'  if lgpl_3_match( tmp_name )
      return 'LGPL-3.0+' if lgpl_3_or_later_match( tmp_name )

      return 'Apache License 1.0' if apache_license_10_match( tmp_name )
      return 'Apache License 1.1' if apache_license_11_match( tmp_name )
      return 'Apache License 2.0' if apache_license_20_match( tmp_name )

      return 'Eclipse Public License 1.0' if eclipse_match( tmp_name )
      return 'Eclipse Distribution License 1.0' if eclipse_distribution_match( tmp_name )

      return 'Artistic License 1.0' if artistic_10_match( tmp_name )
      return 'Artistic License 2.0' if artistic_20_match( tmp_name )
      name
    end

    def mpl_10_match name
      name.match(/\AMozilla Public License Version 1\.0\z/i) ||
      name.match(/\AMPL\-1\.0\z/i) ||
      name.match(/\AMPL 1\.0\z/i)
    end

    def mpl_11_match name
      name.match(/\AMozilla Public License Version 1\.1\z/i) ||
      name.match(/\AMozilla Public License 1\.1 \(MPL 1\.1\)\z/i) ||
      name.match(/\AMPL\-1\.1\z/i) ||
      name.match(/\AMPL 1\.1\z/i)
    end

    def mpl_20_match name
      name.match(/\AMozilla Public License Version 2\.0\z/i) ||
      name.match(/\AMozilla Public License 2\.0 \(MPL 2\.0\)\z/i) ||
      name.match(/\AMPL\-2\.0\z/i) ||
      name.match(/\AMPL 2\.0\z/i)
    end

    def ruby_match name
      name.match(/\ARuby\z/i) ||
      name.match(/\ARuby 1\.8\z/i) ||
      name.match(/\ARuby License\z/i)
    end

    def mit_match name
      name.match(/\AMIT\z/i) ||
      name.match(/\AMIT License\z/i)
    end

    def eclipse_match name
      name.match(/\AEclipse\z/i) ||
      name.match(/\AEclipse License\z/i) ||
      name.match(/\AEclipse Public License\z/i) ||
      name.match(/\AEclipse Public License 1\.0\z/i) ||
      name.match(/\AEclipse Public License v1\.0\z/i) ||
      name.match(/\AEclipse Public License v 1\.0\z/i) ||
      name.match(/\AEclipse Public License Version 1\.0\z/i) ||
      name.match(/\AEclipse Public License Version 1\.0\z/i)
    end

    def eclipse_distribution_match name
      name.match(/\AEclipse Distribution\z/i) ||
      name.match(/\AEclipse Distribution License v\. 1\.0\z/i) ||
      name.match(/\AEclipse Distribution License 1\.0\z/i) ||
      name.match(/\AEclipse Distribution License v1\.0\z/i) ||
      name.match(/\AEclipse Distribution License v 1\.0\z/i) ||
      name.match(/\AEclipse Distribution License Version 1\.0\z/i) ||
      name.match(/\AEclipse Distribution License Version 1\.0\z/i)
    end

    def bsd_match name
      name.match(/\ABSD\z/) ||
      name.match(/\ABSD License\z/i)
    end

    def bsd_style_match name
      name.match(/\BSD style\z/i) ||
      name.match(/\BSD style License\z/i) ||
      name.match(/\BSD-style License\z/i)
    end

    def new_bsd_match name
      name.match(/\New BSD\z/i) ||
      name.match(/\New BSD License\z/i)
    end

    def bsd_3_clause_match name
      name.match(/\BSD 3-Clause\z/) ||
      name.match(/\BSD 3-Clause License\z/) ||
      name.match(/\ARevised BSD\z/i) ||
      name.match(/\ABSD Revised\z/i) ||
      name.match(/\ABSD New\z/i)
    end

    def gpl_match name
      name.match(/\AGPL\z/i)
    end

    def gpl_20_match name
      name.match(/\AGPL 2\z/i) ||
      name.match(/\AGPL\-2\z/i) ||
      name.match(/\AGPLv2\+\z/i) ||
      name.match(/\AGPL 2\.0\z/i) ||
      name.match(/\AGPL\-2\.0\z/i)
    end

    def lgpl_2_match name
      name.match(/\ALGPL 2\z/i) ||
      name.match(/\ALGPLv2\z/i) ||
      name.match(/\ALGPL\-2\z/i) ||
      name.match(/\AGNU Lesser General Public License v2\.0 only\z/i)
    end

    def lgpl_20_match name
      name.match(/\ALGPL version 2\.0\z/i) ||
      name.match(/\ALGPL v2.0\z/i) ||
      name.match(/\ALGPL 2\.0\z/i) ||
      name.match(/\ALGPLv2\.0\z/i) ||
      name.match(/\ALGPL\-2\.0\z/i) ||
      name.match(/\AGNU Lesser General Public License v2\.0 only\z/i) ||
      name.match(/\AGNU Lesser General Public License Version 2\.0\z/i)
    end

    def lgpl_21_match name
      name.match(/\ALGPL version 2\.1\z/i) ||
      name.match(/\ALGPL v2.1\z/i) ||
      name.match(/\ALGPL 2\.1\z/i) ||
      name.match(/\ALGPLv2\.1\z/i) ||
      name.match(/\ALGPL\-2\.1\z/i) ||
      name.match(/\AGNU Lesser General Public License v2\.1 only\z/i) ||
      name.match(/\AGNU Lesser General Public License Version 2\.1\z/i)
    end

    def lgpl_3_match name
      name.match(/\ALGPL 3\z/i) ||
      name.match(/\ALGPLv3\z/i) ||
      name.match(/\ALGPL\-3\z/i) ||
      name.match(/\ALGPL\z/i) ||
      name.match(/\AGnu Lesser Public License\z/i) ||
      name.match(/\AGNU Lesser General Public Licence\z/i) ||
      name.match(/\AGNU LESSER GENERAL PUBLIC LICENSE\z/i) ||
      name.match(/\AGNU Lesser General Public Licence v3\.0 only\z/i) ||
      name.match(/\AGNU Lesser General Public License v3\.0 only\z/i)
    end

    def lgpl_3_or_later_match name
      name.match(/\ALGPL 3\+\z/i) ||
      name.match(/\ALGPLv3\+\z/i) ||
      name.match(/\ALGPL\-3\+\z/i) ||
      name.match(/\AGNU Lesser General Public License v3\.0 or later\z/i)
    end

    def artistic_10_match name
      name.match(/\AArtistic 1\.0\z/i) ||
      name.match(/\AArtistic\-1\.0\z/i) ||
      name.match(/\AArtistic License\z/i) ||
      name.match(/\AArtistic License 1\.0\z/i)
    end

    def artistic_20_match name
      name.match(/\AArtistic 2.0\z/) ||
      name.match(/\AArtistic License 2.0\z/i)
    end

    def apache_license_10_match name
      name.match(/\AApache 1\z/i) ||
      name.match(/\AApache\-1\z/i) ||
      name.match(/\AApache 1\.0\z/i) ||
      name.match(/\AApache\-1\.0\z/i) ||
      name.match(/\AApache License 1\z/i) ||
      name.match(/\AApache License 1\.0\z/i) ||
      name.match(/\AApache License Version 1\.0\z/i) ||
      name.match(/\AApache Software License Version 1\.0\z/i)
    end

    def apache_license_11_match name
      name.match(/\AApache 1\.1\z/i) ||
      name.match(/\AApache\-1\.1\z/i) ||
      name.match(/\AApache License 1\.1\z/i) ||
      name.match(/\AApache License Version 1\.1\z/i) ||
      name.match(/\AApache Software License Version 1\.1\z/i)
    end

    def apache_license_20_match name
      name.match(/\AApache\z/i) ||
      name.match(/\AApache 2\z/i) ||
      name.match(/\AApache\-2\z/i) ||
      name.match(/\AApache 2\.0\z/i) ||
      name.match(/\AApache\-2\.0\z/i) ||
      name.match(/\AApache License\z/i) ||
      name.match(/\AApache License 2\z/i) ||
      name.match(/\AApache License 2\.0\z/i) ||
      name.match(/\AApache License Version 2\.0\z/i) ||
      name.match(/\AApache Software License\z/i) ||
      name.match(/\AApache Software Licenses\z/i) ||
      name.match(/\AApache Software License Version 2\.0\z/i)
    end

    def cddl_match name
      name.match(/\ACDDL\z/i) ||
      name.match(/\ACOMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0\z/i) ||
      name.match(/\ACommon Development and Distribution License (CDDL) v1.0\z/i)
    end

    def cpl_10_match name
      name.match(/\ACPL\-1\.0\z/i) ||
      name.match(/\ACPL 1\.0\z/i) ||
      name.match(/\ACommon Public License 1\z/i) ||
      name.match(/\ACommon Public License 1\.0\z/i) ||
      name.match(/\ACommon Public License v 1\.0\z/i)
      name.match(/\ACommon Public License Version 1\z/i) ||
      name.match(/\ACommon Public License Version 1\.0\z/i)
      name.match(/\ACommon Public License Version 1\.0\z/i) ||
      name.match(/\ACommon Public License 1\.0\z/i) ||
      name.match(/\ACommon Public License v 1\.0\z/i)
    end


  end

end
