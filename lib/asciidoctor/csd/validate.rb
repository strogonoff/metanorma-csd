module Asciidoctor
  module Csd
    class Converter < Standoc::Converter
      def content_validate(doc)
        super
        bibdata_validate(doc.root)
      end

      def bibdata_validate(doc)
        doctype_validate(doc)
        stage_validate(doc)
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(directive guide specification standard report administrative amendment
        technical-corrigendum advisory).include? doctype or
          warn "Document Attributes: #{doctype} is not a recognised document type"
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(proposal working-draft committee-draft draft-standard final-draft
        published withdrawn).include? stage or
          warn "Document Attributes: #{stage} is not a recognised status"
      end
    end
  end
end
