package com.galaxycleaner.app.ui.albums

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.galaxycleaner.app.R
import com.galaxycleaner.app.adapter.MacroAdapter
import com.galaxycleaner.app.databinding.FragmentMacrosBinding
import com.galaxycleaner.app.model.MacroPreset
import com.galaxycleaner.app.service.AlbumManager
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class MacrosFragment : Fragment() {

    private var _binding: FragmentMacrosBinding? = null
    private val binding get() = _binding!!
    private lateinit var albumManager: AlbumManager
    private lateinit var macroAdapter: MacroAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMacrosBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        albumManager = AlbumManager(requireContext())
        setupRecyclerView()
        loadMacros()
    }

    override fun onResume() {
        super.onResume()
        loadMacros()
    }

    private fun setupRecyclerView() {
        macroAdapter = MacroAdapter(
            onRun = { preset -> executeMacro(preset) },
            onDelete = { preset -> confirmDeleteMacro(preset) }
        )
        binding.recyclerMacros.apply {
            adapter = macroAdapter
            layoutManager = LinearLayoutManager(requireContext())
        }
    }

    private fun loadMacros() {
        val macros = albumManager.loadMacroPresets()
        macroAdapter.submitList(macros)
        binding.layoutEmptyMacros.visibility = if (macros.isEmpty()) View.VISIBLE else View.GONE
        binding.recyclerMacros.visibility = if (macros.isEmpty()) View.GONE else View.VISIBLE
    }

    private fun executeMacro(preset: MacroPreset) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val count = albumManager.executeMacro(preset)
                val actionStr = getString(
                    if (preset.action == com.galaxycleaner.app.model.MacroAction.HIDE)
                        R.string.action_hide else R.string.action_show
                ).lowercase()
                Snackbar.make(
                    binding.root,
                    "Macro executada: $count album(ns) ${actionStr}(s)",
                    Snackbar.LENGTH_SHORT
                ).show()
            } catch (e: Exception) {
                Snackbar.make(binding.root, "Erro ao executar macro: ${e.message}", Snackbar.LENGTH_LONG).show()
            }
        }
    }

    private fun confirmDeleteMacro(preset: MacroPreset) {
        MaterialAlertDialogBuilder(requireContext())
            .setTitle(R.string.confirm_delete_macro)
            .setMessage(preset.name)
            .setPositiveButton(R.string.delete) { _, _ ->
                albumManager.deleteMacroPreset(preset.id)
                loadMacros()
                Snackbar.make(binding.root, "Macro excluida", Snackbar.LENGTH_SHORT).show()
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
