require 'spec_helper'

include PuppetModuleGems::Constants

describe PuppetModuleGems::DependenciesParser do
  describe '#build_gem_matrix' do

    it 'should import data from dependencies file' do
      dep_hash = {
        'dependencies' => {
          'shared' =>
            {'b0' => [{'gem' => 'c0', 'version' => '> 0.0.1'}],
             'b1' => [{'gem' => 'c1', 'version' => '< 1.0.0'}]},
          'a0' =>
            {'b1' => [{'gem' => 'c2'}]},
          'a1' =>
            {'b0' => [{'gem' => 'c3'}]},
        }
      }

      allow(YAML).to receive(:load_file).with('/tmp/foofile').and_return(dep_hash)
      result = PuppetModuleGems::DependenciesParser.build_gem_matrix('/tmp/foofile')

      expect(result).to be_a Hash

      # Validate that the matrix is built with correct keys
      expect(result.keys).to match_array(['a0-b0', 'a0-b1', 'a1-b0', 'a1-b1'])

      # Validate that the matrix is built with correct shared deps
      ['a0-b0', 'a1-b0'].each do |key|
        expect(result[key]).to     include({'gem' => 'c0', 'version' => '> 0.0.1'})
        expect(result[key]).not_to include({'gem' => 'c1', 'version' => '< 1.0.0'})
      end

      ['a0-b1', 'a1-b1'].each do |key|
        expect(result[key]).to     include({'gem' => 'c1', 'version' => '< 1.0.0'})
        expect(result[key]).not_to include({'gem' => 'c0', 'version' => '> 0.0.1'})
      end

      # Validate that the matrix has specific deps
      expect(result['a0-b0']).not_to include({'gem' => 'c2'})
      expect(result['a0-b1']).to     include({'gem' => 'c2'})
      expect(result['a1-b0']).to     include({'gem' => 'c3'})
      expect(result['a1-b1']).not_to include({'gem' => 'c3'})
    end

    describe 'should validate input file' do

      it 'is not empty' do
        allow(YAML).to receive(:load_file).with('/tmp/foofile').and_return(false)
        expect { PuppetModuleGems::DependenciesParser.build_gem_matrix('/tmp/foofile') }.
          to raise_error(SystemExit, 'FAILED: [DependenciesParser] Failed to read Dependencies configuration file.')
      end

      it 'starts with correct key' do
        allow(YAML).to receive(:load_file).with('/tmp/foofile').and_return({'foo' => 'bar'})
        expect { PuppetModuleGems::DependenciesParser.build_gem_matrix('/tmp/foofile') }.
          to raise_error(SystemExit, 'FAILED: [DependenciesParser] Dependencies configuration is invalid. Missing top-level \'dependencies\' key.')
      end

      it 'has content' do
        allow(YAML).to receive(:load_file).with('/tmp/foofile').and_return({'dependencies' => nil})
        expect { PuppetModuleGems::DependenciesParser.build_gem_matrix('/tmp/foofile') }.
          to raise_error(SystemExit, 'FAILED: [DependenciesParser] Dependencies configuration contains no dependencies.')
      end

    end

    describe 'default dependencies'
    it 'should import data from default dependencies file for dev' do
      result = PuppetModuleGems::DependenciesParser.build_gem_matrix(DEPENDENCIES_FILE)
      expect(result).to be_a Hash
      ['posix-dev-r2.1', 'posix-dev-r2.3', 'posix-dev-r2.4', 'win-dev-r2.1', 'win-dev-r2.3', 'win-dev-r2.4'].each do |key|
        expect(result[key]).to include({'gem'=>'beaker-task_helper', 'version'=>['>= 1.1.0', '< 2.0.0']})
        expect(result[key]).to include({'gem'=>'gettext-setup', 'version'=>'~> 0.26'})
        expect(result[key]).to include({'gem'=>'metadata-json-lint', 'version'=>['>= 2.0.2', '< 3.0.0']})
        expect(result[key]).to include({'gem'=>'mocha', 'version'=>['>= 1.0.0', '< 1.2.0']})
        expect(result[key]).to include({'gem'=>'parallel_tests', 'version'=>['>= 2.14.1', '< 2.14.3']})
        expect(result[key]).to include({'gem'=>'pry', 'version'=>'~> 0.10.4'})
        expect(result[key]).to include({'gem'=>'puppet-lint', 'version'=>['>= 2.3.0', '< 3.0.0']})
        expect(result[key]).to include({'gem'=>'puppet_pot_generator', 'version'=>'~> 1.0'})
        expect(result[key]).to include({'gem'=>'puppet-syntax', 'version'=>['>= 2.4.1', '< 3.0.0']})
        expect(result[key]).to include({'gem'=>'puppetlabs_spec_helper', 'version'=>['>= 2.3.1', '< 3.0.0']})
        expect(result[key]).to include({'gem'=>'rainbow', 'version'=>['>= 2.0.0', '< 2.2.0']})
        expect(result[key]).to include({'gem'=>'rspec-puppet', 'version'=>['>= 2.3.2', '< 3.0.0']})
        expect(result[key]).to include({'gem'=>'rspec-puppet-facts', 'version'=>'~> 1.8'})
        expect(result[key]).to include({'gem'=>'rubocop', 'version'=>'~> 0.49'})
        expect(result[key]).to include({'gem'=>'rubocop-i18n', 'version'=>'~> 1.0'})
        expect(result[key]).to include({'gem'=>'rubocop-rspec', 'version'=>'~> 1.15'})
        expect(result[key]).to include({'gem'=>'rspec_junit_formatter', 'version'=>'~> 0.2'})
        expect(result[key]).to include({'gem'=>'specinfra', 'version'=>'2.67.3'})
      end
    end
  end
end

