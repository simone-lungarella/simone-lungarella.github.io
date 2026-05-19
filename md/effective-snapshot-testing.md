---
title: Effective Snapshot Testing
date: 2026-05-17
description: The power of snapshot testing and how to make them effective
lang: en
---

Snapshot tests verify the *entire state* of a system rather than individual
assertions. This significantly reduces the effort required to write tests,
as a single snapshot represents the expected outcome.

Keeping in mind that a snapshot test should be as narrow as it can be so that any
changes to the snapshot are easily reviewed, let's focus on a simple `java`
example:

```java
@Test
@Sql(scripts = "classpath:fixture/io2_data.sql")
void computes_kpis_from_db_state() {
    var result = kpiService.calculateKpis(IO2, ALL);
    // Verify snapshot
    JsonApprovals.verifyJson(new Gson().toJson(result));
}
```

In this example, a `fixture` provides data preparation for a test and the
snapshot represent a single table state after logic execution. Even in complex
systems, a snapshot should be very small; otherwise it becomes hard to
maintain.

---

One important thing to consider is to make sure that the final snapshot is
deterministic to avoid flaky tests. In the example where we have `JSON`
snapshot, a developer should:

- Remove inconsistent fields such as random `UUID`s;
- Remove or normalize dates, floating point numbers, etc.;
- Order each field in the same way so to have a result that can be diffed with
  the previous test iteration;

```java
@Test
@Sql(scripts = "classpath:fixture/io2_data.sql")
void computes_kpis_from_db_state() {

    // Enforce time usage to have deterministic dates
    try (WithTimeZone tz = new WithTimeZone("UTC")) {

        var result = kpiService.calculateKpis(IO2, ALL);
        var normalizedJson = new Gson().toJson(normalize(result));

        JsonApprovals.verifyJson(normalizedJson);
    }
}
```

A risk with tests like this, is that the simplicity of the assertion makes it
easy to correct when a test starts failing, for that reason I suggest to use
classic assertions to capture broader concepts that should remain `true` for
the particular test.

```java
@Test
@Sql(scripts = "classpath:fixture/io2_data.sql")
void computes_kpis_from_db_state() {

    // Enforce time usage to have deterministic dates
    try (WithTimeZone tz = new WithTimeZone("UTC")) {

        var result = kpiService.calculateKpis(IO2, ALL);
        var normalizedJson = new Gson().toJson(normalize(result));

        assertNull(result.getError());
        assertEquals(100, result.getProgressPercent());

        JsonApprovals.verifyJson(normalizedJson);
    }
}
```

This does mitigate the risk but does not prevent developers from updating
snapshots without fully understanding the change; however, if you are serious
about programming, a good approach to this problem is fixing a snapshot instead
of replacing it when code changes invalidate the test. For that, one can
leverage tools such as `jq` which is useful to compare two `JSON` files.

For example, you can normalize and diff snapshots locally:

```bash
diff <(jq 'del(.timestamp) | sort_keys' received.json) \
     <(jq 'del(.timestamp) | sort_keys' approved.json)
```

This approach makes any change intentional and specific so that any code review
can treat it just like any other piece of logic.

## Other readings

- [Testing can be fun, actually](https://giacomocavalieri.me/writing/testing-can-be-fun-actually) by Giacomo Cavalieri;
- [Snapshot testing in Java](https://github.com/approvals/ApprovalTests.Java/blob/master/approvaltests/docs/README.md)  with ApprovalsTest;

