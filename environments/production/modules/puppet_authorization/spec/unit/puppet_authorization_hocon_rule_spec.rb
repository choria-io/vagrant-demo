require 'spec_helper'

describe Puppet::Type.type(:puppet_authorization_hocon_rule) do
  let(:resource) {
    Puppet::Type.type(:puppet_authorization_hocon_rule).new(
      :name  => 'auth rule',
      :path  => '/tmp/auth.conf',
      :value => {},
    )
  }

  it 'is ensurable' do
    resource[:ensure] = :present
    expect(resource[:ensure]).to be(:present)
    resource[:ensure] = :absent
    expect(resource[:ensure]).to be(:absent)
  end

  it 'raises an error if an invalid ensure value is passed' do
    expect { resource[:ensure] = 'file' }.to raise_error \
      Puppet::Error, /Invalid value "file"/
  end

  it 'accepts valid hash values' do
    hash = { 'key' => 'value' }
    resource[:value] = hash
    expect(resource[:value]).to eq([hash])
  end

  it 'raises an error with invalid hash values' do
    expect { resource[:value] = 4 }.to raise_error \
      Puppet::Error, /Value must be a hash/
  end

  context 'raises an error with invalid allow/deny values' do
    it 'raises an error if both certname and extensions are in the same map' do
      expect { resource[:value] = {'allow' => {'certname' => 'foo', 'extensions' => {'bar' => 'baz'}}} }.to \
        raise_error Puppet::Error, /Only one of 'certname' and 'extensions' are allowed keys in a allow hash./
    end

    it 'raises an error if an unknown key is in the allow/deny map' do
      expect { resource[:value] = {'deny' => {'goodness me' => 'foo', 'extensions' => {'bar' => 'baz'}}} }.to \
        raise_error Puppet::Error, /Only one of 'certname' and 'extensions' are allowed keys in a deny hash. Found 'goodness me'./
    end

    it 'raises an error if neither certname nor extensions are in an allow/deny map' do
      expect { resource[:value] = {'allow' => {}} }.to \
        raise_error Puppet::Error, /Only one of 'certname' and 'extensions' are allowed keys in a allow hash./
    end

    context 'checks maps in allow/deny arrays' do
      it 'raises an error if both certname and extensions are in the same map' do
        expect { resource[:value] = {'allow' => ['node1', 'node2', {'certname' => 'foo', 'extensions' => {'bar' => 'baz'}}]} }.to \
          raise_error Puppet::Error, /Only one of 'certname' and 'extensions' are allowed keys in a allow hash./
      end

      it 'raises an error if an unknown key is in the allow/deny map' do
        expect { resource[:value] = {'deny' => [{'goodness me' => 'foo', 'extensions' => {'bar' => 'baz'}}, 'node3', { 'extensions' => {'bar' => 'baz'}}]} }.to \
          raise_error Puppet::Error, /Only one of 'certname' and 'extensions' are allowed keys in a deny hash. Found 'goodness me'./
      end

      it 'raises an error if neither certname nor extensions are in an allow/deny map' do
        expect { resource[:value] = {'allow' => [{}, {'certname' => 'foo'}]} }.to \
          raise_error Puppet::Error, /Only one of 'certname' and 'extensions' are allowed keys in a allow hash./
      end
    end
  end

  it 'raises an error with invalid path values' do
    expect { resource[:path] = "not/absolute/path" }.to raise_error \
      Puppet::Error, /File paths must be fully qualified/
  end
end
