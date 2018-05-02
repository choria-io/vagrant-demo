require 'puppetlabs_spec_helper/module_spec_helper'

shared_examples 'fail' do
  it 'fails' do
    expect { subject.call }.to raise_error(/#{regex}/)
  end
end
