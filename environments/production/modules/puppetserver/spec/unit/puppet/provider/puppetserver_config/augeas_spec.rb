#!/usr/bin/env rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:puppetserver_config).provider(:augeas)

describe provider_class do
  context "with empty file" do
    let(:tmptarget) { aug_fixture("empty") }
    let(:target) { tmptarget.path }

    it "should create simple new entry" do
      apply!(Puppet::Type.type(:puppetserver_config).new(
        :name     => "foo",
        :key      => "foo",
        :path     => "bar",
        :value    => "42",
        :target   => target,
        :provider => "augeas"
      ))

      aug_open(target, "Trapperkeeper.lns") do |aug|
        expect(aug.get("@hash/@simple/@value")).to eq("42")
      end
    end

    it "should create an array entry" do
      apply!(Puppet::Type.type(:puppetserver_config).new(
        :name     => "foo",
        :key      => "foo",
        :path     => "bar",
        :value    => ["42", "24"],
        :target   => target,
        :provider => "augeas"
      ))

      aug_open(target, "Trapperkeeper.lns") do |aug|
        expect(aug.get("@hash/@array/1")).to eq("42")
        expect(aug.get("@hash/@array/2")).to eq("24")
      end
    end
  end

  context "with full file" do
    let(:tmptarget) { aug_fixture("full") }
    let(:target) { tmptarget.path }

    describe "when creating settings" do
      it "should create a simple entry" do
        apply!(Puppet::Type.type(:puppetserver_config).new(
          :name     => "foo",
          :key      => "foo",
          :path     => "bar",
          :value    => "42",
          :target   => target,
          :provider => "augeas"
        ))

        aug_open(target, "Trapperkeeper.lns") do |aug|
          expect(aug.get("@hash/@simple[.='foo']/@value")).to eq("42")
        end
      end

      it "should create an array entry" do
        apply!(Puppet::Type.type(:puppetserver_config).new(
          :name     => "foo",
          :key      => "foo",
          :path     => "bar",
          :value    => ["42", "24"],
          :target   => target,
          :provider => "augeas"
        ))

        aug_open(target, "Trapperkeeper.lns") do |aug|
          expect(aug.get("@hash/@array[.='foo']/1")).to eq("42")
          expect(aug.get("@hash/@array[.='foo']/2")).to eq("24")
        end
      end
    end

    describe "when deleting settings" do
      it "should delete a setting" do
        apply!(Puppet::Type.type(:puppetserver_config).new(
          :name     => "client-whitelist",
          :key      => "client-whitelist",
          :path     => "puppet-admin",
          :ensure   => :absent,
          :type     => :array,
          :target   => target,
          :provider => "augeas"
        ))

        aug_open(target, "Trapperkeeper.lns") do |aug|
          expect(aug.match("@hash/@array[.='client-whitelist']").size).to eq(0)
        end
      end
    end

    describe "when updating settings" do
      it "should replace a setting" do
        apply!(Puppet::Type.type(:puppetserver_config).new(
          :name     => "client-whitelist",
          :key      => "client-whitelist",
          :path     => "puppet-admin",
          :value    => [ "foo", "bar" ],
          :target   => target,
          :provider => "augeas"
        ))

        aug_open(target, "Trapperkeeper.lns") do |aug|
          expect(aug.get("@hash/@array[.='client-whitelist']/1")).to eq("foo")
          expect(aug.get("@hash/@array[.='client-whitelist']/2")).to eq("bar")
        end
      end
    end
  end

  context "with broken file" do
    let(:tmptarget) { aug_fixture("broken") }
    let(:target) { tmptarget.path }

    it "should fail to load" do
      txn = apply(Puppet::Type.type(:puppetserver_config).new(
        :name     => "foo",
        :value    => "yes",
        :target   => target,
        :provider => "augeas"
      ))

      expect(txn.any_failed?).not_to eq(nil)
      expect(@logs.first.level).to eq(:err)
      expect(@logs.first.message.include?(target)).to eq(true)
    end
  end
end

