require 'spec_helper'

describe 'collectd::plugin::curl::page', type: :define do
  let :facts do
    {
      osfamily: 'Debian',
      collectd_version: '4.8.0',
      operatingsystemmajrelease: '7',
      python_dir: '/usr/local/lib/python2.7/dist-packages'
    }
  end

  let :pre_condition do
    'include ::collectd'
  end

  context 'simple case' do
    let(:title) { 'test' }
    let :params do
      {
        url: 'http://www.example.com/query',
        matches: [{ 'regex' => 'SPAM \\(Score: (-?[0-9]+\\.[0-9]+)\\)', 'dstype' => 'CounterAdd', 'type' => 'counter' }],
        measureresponsecode: true
      }
    end

    it 'Will create /etc/collectd/conf.d/curl-test.conf' do
      is_expected.to contain_file('/etc/collectd/conf.d/curl-test.conf').with_content("<Plugin curl>\n  <Page \"test\">\n    URL \"http://www.example.com/query\"\n    MeasureResponseCode true\n  <Match>\n    Regex \"SPAM \\(Score: (-?[0-9]+\\.[0-9]+)\\)\"\n    DSType \"CounterAdd\"\n    Type \"counter\"\n  </Match>\n\n  </Page>\n</Plugin>\n")
    end
  end
end
