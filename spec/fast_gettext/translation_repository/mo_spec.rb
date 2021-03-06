require "spec_helper"

SingleCov.covered! uncovered: 1

describe 'FastGettext::TranslationRepository::Mo' do
  before do
    @rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec', 'locale'))
    @rep.is_a?(FastGettext::TranslationRepository::Mo).should == true
  end

  it "can be built" do
    @rep.available_locales.sort.should == ['de','en','gsw_CH']
  end

  it "can translate" do
    FastGettext.locale = 'de'
    @rep['car'].should == 'Auto'
  end

  it "can pluralize" do
    FastGettext.locale = 'de'
    @rep.plural('Axis','Axis').should == ['Achse','Achsen']
  end

  describe :reload do
    before do
      mo_file = FastGettext::MoFile.new('spec/locale/de/LC_MESSAGES/test2.mo')
      empty_mo_file = FastGettext::MoFile.empty

      FastGettext::MoFile.stub(:new).and_return(empty_mo_file)
      FastGettext::MoFile.stub(:new).with('spec/locale/de/LC_MESSAGES/test.mo', :eager_load => false).and_return(mo_file)
    end

    it "can reload" do
      FastGettext.locale = 'de'

      @rep['Untranslated and translated in test2'].should be_nil

      @rep.reload

      @rep['Untranslated and translated in test2'].should == 'Translated'
    end

    it "returns true" do
      @rep.reload.should == true
    end
  end

  it "has access to the mo repositories pluralisation rule" do
    FastGettext.locale = 'en'
    rep = FastGettext::TranslationRepository.build('plural_test',:path=>File.join('spec','locale'))
    rep['car'].should == 'Test'#just check it is loaded correctly
    rep.pluralisation_rule.call(2).should == 3
  end
end
