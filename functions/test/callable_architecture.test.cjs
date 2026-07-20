"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const ts = require("typescript");

const functionsRoot = path.resolve(__dirname, "..");
const sourceRoot = path.join(functionsRoot, "src");

const specifications = [
  [
    "partner_accept_callable.ts",
    "acceptPartnerInvite",
    "./partner_accept_callable",
  ],
  [
    "partner_delete_callable.ts",
    "deleteMyCloudData",
    "./partner_delete_callable",
  ],
  [
    "partner_publish_callable.ts",
    "publishPartnerInvite",
    "./partner_publish_callable",
  ],
  [
    "partner_send_callable.ts",
    "secureSendPartnerInvite",
    "./partner_send_callable",
  ],
];

function parse(relative) {
  return ts.createSourceFile(
    relative,
    fs.readFileSync(
      path.join(sourceRoot, relative),
      "utf8"
    ),
    ts.ScriptTarget.Latest,
    true,
    ts.ScriptKind.TS
  );
}

const indexSource = parse("index.ts");

function hasExportModifier(node) {
  return Boolean(
    node.modifiers &&
    node.modifiers.some(
      modifier =>
        modifier.kind === ts.SyntaxKind.ExportKeyword
    )
  );
}

function findExportedDeclaration(source, exportName) {
  const matches = [];

  function visit(node) {
    if (
      ts.isVariableStatement(node) &&
      hasExportModifier(node)
    ) {
      for (
        const declaration
        of node.declarationList.declarations
      ) {
        if (
          ts.isIdentifier(declaration.name) &&
          declaration.name.text === exportName
        ) {
          matches.push(declaration);
        }
      }
    }

    ts.forEachChild(node, visit);
  }

  visit(source);
  return matches;
}

function importsFirebaseOnCall(source) {
  let found = false;

  function visit(node) {
    if (
      ts.isImportDeclaration(node) &&
      ts.isStringLiteral(node.moduleSpecifier) &&
      node.moduleSpecifier.text ===
        "firebase-functions/v2/https" &&
      node.importClause &&
      node.importClause.namedBindings &&
      ts.isNamedImports(
        node.importClause.namedBindings
      )
    ) {
      found =
        node.importClause.namedBindings.elements.some(
          element => {
            const imported = element.propertyName
              ? element.propertyName.text
              : element.name.text;

            return imported === "onCall";
          }
        );
    }

    ts.forEachChild(node, visit);
  }

  visit(source);
  return found;
}

function initializedByOnCall(declaration) {
  if (
    !declaration.initializer ||
    !ts.isCallExpression(declaration.initializer)
  ) {
    return false;
  }

  const expression = declaration.initializer.expression;

  return (
    (
      ts.isIdentifier(expression) &&
      expression.text === "onCall"
    ) ||
    (
      ts.isPropertyAccessExpression(expression) &&
      expression.name.text === "onCall"
    )
  );
}

function findPublicExport(
  sourceExport,
  moduleSpecifier
) {
  let publicExport = "";

  function visit(node) {
    if (
      ts.isExportDeclaration(node) &&
      node.moduleSpecifier &&
      ts.isStringLiteral(node.moduleSpecifier) &&
      node.moduleSpecifier.text === moduleSpecifier &&
      node.exportClause &&
      ts.isNamedExports(node.exportClause)
    ) {
      for (const element of node.exportClause.elements) {
        const original = element.propertyName
          ? element.propertyName.text
          : element.name.text;

        if (original === sourceExport) {
          publicExport = element.name.text;
        }
      }
    }

    ts.forEachChild(node, visit);
  }

  visit(indexSource);
  return publicExport;
}

function inspectLogging(source) {
  let consoleCalls = 0;
  let loggerCalls = 0;
  const risks = [];

  const sensitiveName =
    /(password|secret|authorization|bearer|access_?token|refresh_?token|id_?token|private_?key|credential|cookie|receipt)/i;

  const wholeObjectName =
    /^(request|req|data|payload|body|context|rawRequest)$/i;

  function inspectLoggerArgument(argument) {
    if (
      ts.isIdentifier(argument) &&
      wholeObjectName.test(argument.text)
    ) {
      risks.push(
        "WHOLE_OBJECT:" + argument.text
      );
    }

    if (
      argument.getText(source).includes("process.env")
    ) {
      risks.push("PROCESS_ENV");
    }

    function inspectProperties(node) {
      if (
        ts.isPropertyAssignment(node) ||
        ts.isShorthandPropertyAssignment(node)
      ) {
        const propertyName = node.name
          ? node.name.getText(source)
          : "";

        if (sensitiveName.test(propertyName)) {
          risks.push(
            "SENSITIVE_PROPERTY:" + propertyName
          );
        }
      }

      ts.forEachChild(node, inspectProperties);
    }

    inspectProperties(argument);
  }

  function visit(node) {
    if (
      ts.isCallExpression(node) &&
      ts.isPropertyAccessExpression(node.expression)
    ) {
      const owner =
        node.expression.expression.getText(source);

      if (owner === "console") {
        consoleCalls += 1;
      }

      if (
        owner === "logger" ||
        owner.endsWith(".logger")
      ) {
        loggerCalls += 1;

        for (const argument of node.arguments) {
          inspectLoggerArgument(argument);
        }
      }
    }

    ts.forEachChild(node, visit);
  }

  visit(source);

  return {
    consoleCalls,
    loggerCalls,
    risks,
  };
}

for (const [
  relative,
  sourceExport,
  moduleSpecifier,
] of specifications) {
  const source = parse(relative);

  test(sourceExport + " parses cleanly", () => {
    assert.equal(
      source.parseDiagnostics.length,
      0
    );
  });

  test(sourceExport + " imports Firebase onCall", () => {
    assert.equal(
      importsFirebaseOnCall(source),
      true
    );
  });

  test(
    sourceExport + " is one exported onCall wrapper",
    () => {
      const declarations =
        findExportedDeclaration(
          source,
          sourceExport
        );

      assert.equal(declarations.length, 1);

      assert.equal(
        initializedByOnCall(declarations[0]),
        true
      );

      assert.ok(
        declarations[0].initializer.arguments.length >= 1
      );
    }
  );

  test(sourceExport + " is publicly re-exported", () => {
    assert.notEqual(
      findPublicExport(
        sourceExport,
        moduleSpecifier
      ),
      ""
    );
  });

  test(sourceExport + " uses safe structured logging", () => {
    const logging = inspectLogging(source);

    assert.equal(logging.consoleCalls, 0);
    assert.ok(logging.loggerCalls > 0);
    assert.deepEqual(logging.risks, []);
  });
}
