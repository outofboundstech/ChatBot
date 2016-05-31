defmodule ChatBot.FSM.Registry do
  # Adapter for Stash.Registry

  @name Stash.Registry

  alias Stash.Registry
  alias Stash.Bucket

  def create(buckets) when is_list(buckets) do
    Enum.map(buckets, fn bucket -> Stash.Registry.create(@name, bucket) end)
  end

  def delete(context, key) when is_atom(context) do
    ChatBot.FSM.Registry.delete(Atom.to_string(context), key)
  end

  def delete(context, key) do
    {:ok, bucket} = Registry.lookup(@name, context)
    Bucket.delete(bucket, key)
  end

  def get(context, key) when is_atom(context) do
    ChatBot.FSM.Registry.get(Atom.to_string(context), key)
  end

  def get(context, key) do
    {:ok, bucket} = Registry.lookup(@name, context)
    Bucket.get(bucket, key)
  end

  def put(context, key, value) when is_atom(context) do
    ChatBot.FSM.Registry.put(Atom.to_string(context), key, value)
  end

  def put(context, key, value) do
    {:ok, bucket} = Registry.lookup(@name, context)
    Bucket.put(bucket, key, value)
  end

  def set(context, key, value) when is_atom(context) do
    ChatBot.FSM.Registry.set(Atom.to_string(context), key, value)
  end

  def set(context, key, value) do
    {:ok, bucket} = Registry.lookup(@name, context)
    Bucket.set(bucket, key, value)
  end
end
