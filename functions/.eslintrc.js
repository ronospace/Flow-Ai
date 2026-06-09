module.exports = {
  root: true,
  env: {
    es2022: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["./tsconfig.json"],
    tsconfigRootDir: __dirname,
    sourceType: "module",
    ecmaVersion: 2022,
  },
  ignorePatterns: [
    "/lib/**/*",
    "/generated/**/*",
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    quotes: ["error", "double"],
    "import/no-unresolved": 0,
    indent: ["error", 2],
  },
};
