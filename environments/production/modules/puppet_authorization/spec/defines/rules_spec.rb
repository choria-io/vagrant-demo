require 'spec_helper'
describe 'puppet_authorization::rule', :type => :define do
  let :pre_condition do
    'puppet_authorization { "/tmp/foo": }'
  end

  let :params do
    {
      :match_request_path => '/foo',
      :match_request_type => 'path',
      :path => '/tmp/foo'
    }.merge(params_override)
  end

  let(:params_override) do
    {}
  end

  let(:facts) {{:concat_basedir => '/dne'}}
  let :title do
    'rule'
  end

  context 'default, one allow' do
    let(:params_override) do
      { :allow => 'bar' }
    end

    it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
      :ensure   => 'present',
      :path     => '/tmp/foo',
      :value    => {
        'match-request' => {
          'path'         => '/foo',
          'type'         => 'path',
          'query-params' => {},
        },
        'allow'         => 'bar',
        'name'          => 'rule',
        'sort-order'    => 200,
      },
    })}
  end

  context 'default, multiple allows' do
    let(:params_override) do
      { :allow => ['foo','bar'] }
    end

    it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
      :ensure   => 'present',
      :path     => '/tmp/foo',
      :value    => {
        'match-request' => {
          'path'         => '/foo',
          'type'         => 'path',
          'query-params' => {},
        },
        'allow'         => ['foo', 'bar'],
        'name'          => 'rule',
        'sort-order'    => 200,
      },
    })}
  end

  context 'non default, deny' do
    let(:params_override) do
      {
        :deny                       => 'bar',
        :ensure                     => 'absent',
        :rule_name                  => 'newrule',
        :match_request_method       => 'put',
        :match_request_query_params => {'foo' => 'bar'},
        :match_request_type         => 'regex',
        :match_request_path         => '/^.*$/',
        :sort_order                 => 1,
        :path                       => '/tmp/bar',
      }
    end

    it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
      :ensure   => 'absent',
      :path     => '/tmp/bar',
      :value    => {
        'match-request' => {
          'path'         => '/^.*$/',
          'type'         => 'regex',
          'query-params' => {'foo' => 'bar'},
          'method'       => 'put',
        },
        'deny'          => 'bar',
        'name'          => 'newrule',
        'sort-order'    => 1,
      },
    })}
  end

  context 'default, multiple allows and denies' do
    let(:params_override) do
      {
        :allow => ['foo', 'bar'],
        :deny  => ['baz', 'bim']
      }
    end

    it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
      :ensure   => 'present',
      :path     => '/tmp/foo',
      :value    => {
        'match-request' => {
          'path'         => '/foo',
          'type'         => 'path',
          'query-params' => {},
        },
        'allow'         => ['foo', 'bar'],
        'deny'          => ['baz', 'bim'],
        'name'          => 'rule',
        'sort-order'    => 200,
      },
    })}
  end

  context 'default, multiple allows and denies with extensions' do
    let(:params_override) do
      {
        :allow => ['foo', 'bar', {'extensions' => {'foo' => 'bar'}}],
        :deny  => {'extensions' => {'foo' => ['bar', 'baz', 'biz']}},
      }
    end

    it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
      :ensure   => 'present',
      :path     => '/tmp/foo',
      :value    => {
        'match-request' => {
          'path'         => '/foo',
          'type'         => 'path',
          'query-params' => {},
        },
        'allow'         => ['foo', 'bar', {'extensions' => {'foo' => 'bar'}}],
        'deny'          => {'extensions' => {'foo' => ['bar', 'baz', 'biz']}},
        'name'          => 'rule',
        'sort-order'    => 200,
      },
    })}
  end

  context 'allow_unauthenticated' do
    let(:params_override) do
      {
        :allow_unauthenticated => true,
        :match_request_method => ['post', 'get', 'head', 'delete'],
      }
    end

    it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
      :ensure   => 'present',
      :path     => '/tmp/foo',
      :value    => {
        'match-request' => {
          'path'         => '/foo',
          'type'         => 'path',
          'query-params' => {},
          'method'       => ['post', 'get', 'head', 'delete'],
        },
        'allow-unauthenticated' => true,
        'name'                  => 'rule',
        'sort-order'            => 200,
      },
    })}
  end

  describe 'failing cases' do
    context 'bad match_request_method' do
      it_behaves_like "fail" do
        let(:params_override) {{ :match_request_method => 'foo' }}
        let(:regex) { 'got String' }
      end
    end

    context 'bad match_request_method 2' do
      it_behaves_like "fail" do
        let(:params_override) {{
            :match_request_method =>
                ['put', 'post', 'get', 'head', 'delete', 'foo'] }}
        let(:regex) { 'got Tuple' }
      end
    end

    context 'allow and allow_unauthenticated' do
      it_behaves_like "fail" do
        let(:params_override) do
          {
            :allow                 => 'foo',
            :allow_unauthenticated => true,
          }
        end
        let(:regex) { 'cannot be specified if' }
      end
    end

    context 'deny and allow_unauthenticated' do
      it_behaves_like "fail" do
        let(:params_override) do
          {
            :deny                  => 'foo',
            :allow_unauthenticated => true,
          }
        end
        let(:regex) { 'cannot be specified if' }
      end
    end

    context 'all three' do
      it_behaves_like "fail" do
        let(:params_override) do
          {
            :allow                 => 'bar',
            :deny                  => 'foo',
            :allow_unauthenticated => true,
          }
        end
        let(:regex) { 'cannot be specified if' }
      end
    end

    context 'none' do
      it_behaves_like "fail" do
        let(:regex) { 'One of' }
      end
    end

    context 'bad match_request_type' do
      it_behaves_like "fail" do
        let(:params_override) {{ :match_request_type => 'foo' }}
        let(:regex) { 'match_request_type' }
      end
    end

    context 'bad ensure' do
      it_behaves_like "fail" do
        let(:params_override) {{ :ensure => 'foo' }}
        let(:regex) { 'ensure' }
      end
    end

    context 'bad rule_name' do
      it_behaves_like "fail" do
        let(:params_override) {{ :rule_name => false }}
        let(:regex) { 'rule_name' }
      end
    end

    context 'bad allow' do
      it_behaves_like "fail" do
        let(:params_override) {{ :allow => 20 }}
        let(:regex) { 'allow' }
      end
    end

    context 'bad allow_unauthenticated' do
      it_behaves_like "fail" do
        let(:params_override) {{ :allow_unauthenticated => 'foo' }}
        let(:regex) { 'allow_unauthenticated' }
      end
    end

    context 'bad deny' do
      it_behaves_like "fail" do
        let(:params_override) {{ :deny => true }}
        let(:regex) { 'deny' }
      end
    end

    context 'bad match_request_path' do
      it_behaves_like "fail" do
        let(:params_override) {{ :match_request_path => 20 }}
        let(:regex) { 'match_request_path' }
      end
    end

    context 'bad match_request_query_params' do
      it_behaves_like "fail" do
        let(:params_override) {{ :match_request_query_params => 'foo' }}
        let(:regex) { 'match_request_query_params' }
      end
    end

    context 'bad sort_order' do
      it_behaves_like "fail" do
        let(:params_override) {{ :sort_order => false }}
        let(:regex) { 'sort_order' }
      end
    end

    context 'bad path' do
      it_behaves_like "fail" do
        let(:params_override) {{ :path => 20 }}
        let(:regex) { 'path' }
      end
    end

    context 'bad path 2' do
      it_behaves_like "fail" do
        let(:params_override) {{ :path => 'foo' }}
        let(:regex) { 'path' }
      end
    end
  end

  context 'class parameters' do
    context 'not required when ensure=>absent' do
      let(:params) {{ :ensure => 'absent', :path => '/tmp/foo' }}

      it { is_expected.to contain_puppet_authorization_hocon_rule('rule-rule').with({
        :ensure   => 'absent',
        :path     => '/tmp/foo',
        :value    => {
          'match-request' => {
            'path'         => 'undef',
            'type'         => 'undef',
            'query-params' => {},
          },
          'allow-unauthenticated' => false,
          'name'                  => 'rule',
          'sort-order'            => 200
        }})}
    end
  end
end
