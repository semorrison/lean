/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
import data.rbtree.find data.rbtree.insert data.rbtree.min_max
universes u

/- TODO(Leo): remove after we cleanup stdlib simp lemmas -/
local attribute [-simp] or.comm or.left_comm or.assoc and.comm and.left_comm and.assoc

namespace rbnode
variables {α : Type u} {lt : α → α → Prop}

lemma is_searchable_of_well_formed {t : rbnode α} [is_strict_weak_order α lt] : t.well_formed lt → is_searchable lt t none none :=
begin
  intro h, induction h,
  { constructor, simp [lift] },
  { subst n', apply is_searchable_insert, assumption }
end

end rbnode

namespace rbtree
variables {α : Type u} {lt : α → α → Prop}

lemma not_mem_mk_rbtree : ∀ (a : α), a ∉ mk_rbtree α lt :=
by simp [has_mem.mem, rbtree.mem, rbnode.mem, mk_rbtree]

variables [decidable_rel lt]

lemma find_correct [is_strict_weak_order α lt] (a : α) (t : rbtree α lt) : a ∈ t ↔ (∃ b, t.find a = some b ∧ a ≈[lt] b) :=
begin cases t, apply rbnode.find_correct, apply rbnode.is_searchable_of_well_formed, assumption end

lemma eqv_of_find_some [is_strict_weak_order α lt] {a b : α} {t : rbtree α lt} : t.find a = some b → a ≈[lt] b :=
begin cases t, apply rbnode.eqv_of_find_some, apply rbnode.is_searchable_of_well_formed, assumption end

lemma contains_correct [is_strict_weak_order α lt] (a : α) (t : rbtree α lt) : a ∈ t ↔ (t.contains a = tt) :=
begin
  have h := find_correct a t,
  simp [h, contains], apply iff.intro,
  { intro h', cases h' with _ h', cases h', simp [*], simp [option.is_some] },
  { intro h',
    generalize heq : find t a = s, cases s with v, simp [heq, option.is_some] at h', contradiction,
    existsi v, simp, apply eqv_of_find_some heq }
end

lemma mem_insert_of_incomp {a b : α} (t : rbtree α lt) : (¬ lt a b ∧ ¬ lt b a) → a ∈ t.insert b :=
begin cases t, apply rbnode.mem_insert_of_incomp end

lemma mem_insert [is_irrefl α lt] : ∀ (a : α) (t : rbtree α lt), a ∈ t.insert a :=
begin intros, apply mem_insert_of_incomp, split; apply irrefl_of lt end

lemma mem_insert_of_equiv {a b : α} (t : rbtree α lt) : a ≈[lt] b → a ∈ t.insert b :=
begin cases t, apply rbnode.mem_insert_of_incomp end

lemma mem_insert_of_mem [is_strict_weak_order α lt] {a : α} {t : rbtree α lt} (b : α) : a ∈ t → a ∈ t.insert b :=
begin cases t, apply rbnode.mem_insert_of_mem end

lemma equiv_or_mem_of_mem_insert [is_strict_weak_order α lt] {a b : α} {t : rbtree α lt} : a ∈ t.insert b → a ≈[lt] b ∨ a ∈ t :=
begin cases t, apply rbnode.equiv_or_mem_of_mem_insert end

lemma incomp_or_mem_of_mem_ins [is_strict_weak_order α lt] {a b : α} {t : rbtree α lt} : a ∈ t.insert b → (¬ lt a b ∧ ¬ lt b a) ∨ a ∈ t :=
equiv_or_mem_of_mem_insert

lemma eq_or_mem_of_mem_ins [is_strict_total_order α lt] {a b : α} {t : rbtree α lt} : a ∈ t.insert b → a = b ∨ a ∈ t :=
begin
  intro h,
  have h₁ := incomp_or_mem_of_mem_ins h,
  have := trichotomous_of lt a b,
  blast_disjs,
  any_goals { simp [*] },
  all_goals { cases h₁, contradiction }
end

lemma mem_of_min_eq [is_irrefl α lt] {a : α} {t : rbtree α lt} : t.min = some a → a ∈ t :=
begin cases t, apply rbnode.mem_of_min_eq end

lemma mem_of_max_eq [is_irrefl α lt] {a : α} {t : rbtree α lt} : t.max = some a → a ∈ t :=
begin cases t, apply rbnode.mem_of_max_eq end

lemma eq_leaf_of_min_eq_none [is_strict_weak_order α lt] {t : rbtree α lt} : t.min = none → t = mk_rbtree α lt :=
begin cases t, intro h, congr, apply rbnode.eq_leaf_of_min_eq_none h end

lemma eq_leaf_of_max_eq_none [is_strict_weak_order α lt] {t : rbtree α lt} : t.max = none → t = mk_rbtree α lt :=
begin cases t, intro h, congr, apply rbnode.eq_leaf_of_max_eq_none h end

lemma min_is_minimal [is_strict_weak_order α lt] {a : α} {t : rbtree α lt} : t.min = some a → ∀ {b}, b ∈ t → a ≈[lt] b ∨ lt a b :=
begin cases t, apply rbnode.min_is_minimal, apply rbnode.is_searchable_of_well_formed, assumption end

lemma max_is_maximal [is_strict_weak_order α lt] {a : α} {t : rbtree α lt} : t.max = some a → ∀ {b}, b ∈ t → a ≈[lt] b ∨ lt b a :=
begin cases t, apply rbnode.max_is_maximal, apply rbnode.is_searchable_of_well_formed, assumption end

end rbtree