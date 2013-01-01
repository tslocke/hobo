# Polymorphic association card replacement?

Originally written by kevinpfromnm on 2010-08-08.

Hello

I've made a polymorphic model, Asset, which can have different asset
associated to it (Images, Videos, etc), accessible via the filable
attribute.

    class Asset
      ...
      belongs_to :filable, :polymorphic => true
    end

I can render a collection of asset just a I've always been able to,
and inside the asset card i can render both a link to the specific
filable element and the filable type.

So how can I:

1. render the card of the joined asset inside the asset card?
2. substitute the entire content of the asset card with the joined
card?

Hope I've been specific enough in describing my problem. I have tried
to render the card using the `<card:filable />` and `<card
with="&this.filable" />` inside the card body-tag, but it only renders
an empty div. 