require "./token_factory"

module TokenProviderInterface
  abstract def jwt : String
end

@[ADI::Register(alias: TokenProviderInterface)]
struct FactoryTokenProvider
  include TokenProviderInterface

  def initialize(
    @factory : TokenFactoryInterface,
    @subscribe : Array(String) = ["*"],
    @publish : Array(String) = ["*"]
  ); end

  def jwt : String
    @factory.create @subscribe, @publish
  end
end
