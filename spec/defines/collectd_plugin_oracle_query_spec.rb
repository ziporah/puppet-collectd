require 'spec_helper'

describe 'collectd::plugin::oracle::query', 'type' => :define do
  let(:facts) do
    {
      osfamily: 'RedHat',
      id: 'root',
      concat_basedir: '/dne',
      path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      collectd_version: '4.8.0',
      operatingsystemmajrelease: '7',
      python_dir: '/usr/local/lib/python2.7/dist-packages'
    }
  end

  let(:config_filename) { '/etc/collectd.d/15-oracle.conf' }

  let(:default_params) do
    {
      statement: "select (select count(*) as count from v$session) ACTUAL_SESSIONS, (select value from v$parameter where name='sessions') MAX_SESSIONS FROM dual",
      results: []
    }
  end

  let(:title) { 'foo' }
  let(:concat_fragment_name) { 'collectd_plugin_oracle_query_foo' }

  # empty values array is technically not valid, but we'll test those cases later
  context 'defaults' do
    let(:params) { default_params }

    it 'provides an oracle query stanza concat fragment' do
      is_expected.to contain_concat__fragment(concat_fragment_name).with(target: config_filename,
                                                                         order: '10')
    end

    it { is_expected.to contain_concat__fragment(concat_fragment_name).with_content(%r{<Query "foo">\s+Statement "select \(select count\(\*\) as count from v\$session\) ACTUAL_SESSIONS, \(select value from v\$parameter where name='sessions'\) MAX_SESSIONS FROM dual"\s+</Query>}m) }
  end

  context 'query results with instance_prefix and values_from string' do
    let(:params) do
      default_params.merge(
        results: [
          {
            'type' => 'sessions',
            'instance_prefix' => 'sessions',
            'values_from' => 'ACTUAL_SESSIONS'
          }
        ]
      )
    end

    it { is_expected.to contain_concat__fragment(concat_fragment_name).with_content(%r{Type "sessions"\s+InstancePrefix "sessions"\s+ValuesFrom "ACTUAL_SESSIONS"}) }
  end

  context 'query results with instance_prefix and values_from array' do
    let(:params) do
      default_params.merge(
        results: [
          {
            'type' => 'sessions',
            'instance_prefix' => 'sessions',
            'values_from' => %w[ACTUAL_SESSIONS MAX_SESSIONS]
          }
        ]
      )
    end

    it { is_expected.to contain_concat__fragment(concat_fragment_name).with_content(%r{Type "sessions"\s+InstancePrefix "sessions"\s+ValuesFrom "ACTUAL_SESSIONS" "MAX_SESSIONS"}) }
  end

  context 'query results with instances_from string and values_from array' do
    let(:params) do
      default_params.merge(
        results: [
          {
            'type' => 'sessions',
            'instances_from' => 'STAT_NAME',
            'values_from' => 'VALUE'
          }
        ]
      )
    end

    it { is_expected.to contain_concat__fragment(concat_fragment_name).with_content(%r{Type "sessions"\s+InstancesFrom "STAT_NAME"\s+ValuesFrom "VALUE"}) }
  end

  context 'query results with instances_from array and values_from array' do
    let(:params) do
      default_params.merge(
        results: [
          {
            'type' => 'sessions',
            'instances_from' => %w[STAT_NAME STAT_VAR],
            'values_from' => %w[VALUE VALUE2]
          }
        ]
      )
    end

    it { is_expected.to contain_concat__fragment(concat_fragment_name).with_content(%r{Type "sessions"\s+InstancesFrom "STAT_NAME" "STAT_VAR"\s+ValuesFrom "VALUE" "VALUE2"}) }
  end
end
