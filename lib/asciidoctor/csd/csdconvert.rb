require "isodoc"

module Asciidoctor
  module Csd
    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class CsdConvert < IsoDoc::Convert
      def self.title(isoxml, _out)
        main = isoxml.at(ns("//title[@language='en']")).text
        @@meta[:doctitle] = main
      end

      def self.subtitle(_isoxml, _out)
        nil
      end

      def self.id(isoxml, _out)
        docnumber = isoxml.at(ns("//csd-standard/id"))
        documentstatus = isoxml.at(ns("//csd-standard/status"))
        @@meta[:docnumber] = docnumber.text
        @@meta[:status] = documentstatus.text if documentstatus
        @@meta[:docnumber] = @@meta[:status] + " " + @@meta[:docnumber]
      end

      def self.populate_template(docxml)
        meta = get_metadata
        docxml.
          gsub(/DOCYEAR/, meta[:docyear]).
          gsub(/DOCNUMBER/, meta[:docnumber]).
          gsub(/DOCTITLE/, meta[:doctitle]).
          gsub(/\[TERMREF\]\s*/, "[SOURCE: ").
          gsub(/\s*\[\/TERMREF\]\s*/, "]").
          gsub(/\s*\[ISOSECTION\]/, ", ").
          gsub(/\s*\[MODIFICATION\]/, ", modified &mdash; ")
      end

      def self.postprocess(result, filename, dir)
        generate_header(filename, dir)
        result = cleanup(Nokogiri::XML(result)).to_xml
        result = populate_template(result)
        File.open("#{filename}.out.html", "w") do |f|
          f.write(result)
        end
        Html2Doc.process(result, filename, 
                         File.join(File.dirname(__FILE__), "wordstyle.css"), 
                         "header.html", dir)
      end

      def self.intropage(out)
        fn = File.join(File.dirname(__FILE__), "csd_intro.html")
        intropage = File.read(fn, encoding: "UTF-8")
        out.parent.add_child intropage
      end

      def self.titlepage(_docxml, div)
        fn = File.join(File.dirname(__FILE__), "csd_titlepage.html")
        titlepage = File.read(fn, encoding: "UTF-8")
        div.parent.add_child titlepage
      end



    end
  end
end

