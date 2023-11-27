defmodule Styler.Plugin do
  @moduledoc """
  Usage:

      defmodule MyApp.MyFormatterPlugin do
        use Styler.Plugin, styles: [Styler.Style.Blocks]
      end
  """

  defmacro __using__(opts) do
    quote do
      @behaviour Mix.Tasks.Format

      @impl Mix.Tasks.Format
      def features(_opts), do: [sigils: [], extensions: [".ex", ".exs"]]

      @impl Mix.Tasks.Format
      def format(input, formatter_opts, opts \\ []) do
        file = formatter_opts[:file]

        styles =
          case Keyword.fetch!(unquote(opts), :styles) do
            style when is_atom(style) ->
              [style]

            styles when is_list(styles) ->
              styles
          end

        opts = Keyword.merge(opts, styles: styles)

        {ast, comments} =
          input
          |> Styler.string_to_quoted_with_comments(to_string(file))
          |> Styler.style(file, opts)

        Styler.quoted_to_string(ast, comments, formatter_opts)
      end
    end
  end
end
